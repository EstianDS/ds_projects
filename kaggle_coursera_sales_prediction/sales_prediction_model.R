### Load required packages
require(tidyverse)
require(lubridate)

### Load data
# Load training data
train_tbl <- as.tbl(read.csv("sales_train.csv"))

# Load test data
submission_tbl <- as.tbl(read.csv("test.csv"))

# Load shop data
shop_tbl <- as.tbl(read.csv("shops.csv"))
item_tbl <- as.tbl(read.csv("items.csv"))
item_cat_tbl <- as.tbl(read.csv("item_categories.csv"))

### Data exploration + visualization
str(train_tbl)
summary(train_tbl)

###### Get and idea of sales by shop
train_tbl %>% 
  ##### Group by shop and date block
  group_by(shop_id,date_block_num) %>%
  summarise(item_cnt_day=sum(item_cnt_day)) %>% 
  #### Group by shopid
  group_by(shop_id) %>% 
  summarise(item_cnt_day=sum(item_cnt_day),
            month_count=n()) %>%
  ##### Some shops have only been open for a very limited amount of months, 
  ##### and naturally they vary a lot in terms of sales
  ggplot(aes(x=month_count,y=item_cnt_day))+geom_point()+ggtitle("Store sales behaviour")

####### Get an idea of sales for each item
train_tbl %>% 
  ##### Group by item_id and date block
  group_by(item_id,date_block_num) %>%
  summarise(item_cnt_day=sum(item_cnt_day)) %>% 
  #### Group by item_id
  group_by(item_id) %>% 
  summarise(item_cnt_day=sum(item_cnt_day),
            month_count=n()) %>%
  arrange(-item_cnt_day) %>% 
  ungroup() %>% 
  mutate(item_rank=c(1:n())) %>% 
  mutate(percentage=item_cnt_day/sum(item_cnt_day)) %>% 
  mutate(cum_percentage=cumsum(percentage)) %>% 
  gather(key,value,percentage,cum_percentage) %>% 
  ###### One big outlier, but other than that sales are more uniformly distributed accross items than I have ever seen in industry
  ggplot(aes(x=item_rank,y=value))+geom_col()+facet_grid(key~.,scales = "free")+ggtitle("Item Volume Distribution")#+coord_cartesian(xlim = c(0,100))


train_tbl %>% 
  ##### Group by item_id and date block
  group_by(item_id,date_block_num) %>%
  summarise(item_cnt_day=sum(item_cnt_day)) %>% 
  #### Group by item_id
  group_by(item_id) %>% 
  summarise(item_cnt_day=sum(item_cnt_day),
            month_count=n()) %>% 
  group_by(month_count) %>% 
  summarise(item_count=n()) %>% 
  ungroup() %>% 
  mutate(percentage=item_count/sum(item_count)) %>% 
  mutate(cum_percentage=cumsum(percentage)) %>%
  gather(key,value,percentage,cum_percentage) %>% 
  ###### 50% of items have less than a years worth of sales data, seasonality will be difficult
  ggplot(aes(x=month_count,y=value))+geom_col()+facet_grid(key~.,scales = "free")+ggtitle("Item Sales Life Distribution")
  


### Define some cleansing and transformation functions
transform_data <- function(tibble,max_lag, top_n_correlated){
  max_lag <- 4
  top_n_correlated <- 4
  train_tbl %>%
    ###### Calculate monthly/weekly/daily average,min,max sales by item/shop over various lags
    ## Create lag values
    mutate(lags=paste(c(0:max_lag),collapse = "-")) %>% 
    separate(lags,into = paste0("lag_",c(0:max_lag)),remove = TRUE) %>% 
    gather(lag,lag_value,paste0("lag_",c(0:max_lag))) %>% 
    mutate(lag_value=as.numeric(lag_value)) %>%  
    ## Define date partitions
    mutate(day=as.Date(as.character(date),"%d.%m.%Y")+days(-1*lag_value),
           week=floor_date(day,unit = "week")+weeks(-1*lag_value),
           month=floor_date(day,unit = "month")+months(-1*lag_value))
    
}






