### Load required packages
require(tidyverse)

### Load data
# Load training data
train_tbl <- as.tbl(read.csv("sales_train.csv"))

# Load test data
submission_tbl <- as.tbl(read.csv("test.csv"))

# Load shop data
shop_tbl <- as.tbl(read.csv("shops.csv"))
item_tbl <- as.tbl(read.csv("items.csv"))
item_cat_tbl <- as.tbl(read.csv("item_categories.csv"))

### Define some cleansing and transformation functions


### Data exploration + visualization
str(train_tbl)
summary(train_tbl)

