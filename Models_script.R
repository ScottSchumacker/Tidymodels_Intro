# Scott Schumacker
# Tidymodels Introduction

################## Building a model #####################

# Loading packages
library(tidymodels)
library(readr)
library(broom.mixed)
library(dotwhisker) 

# Obtaining Data
urchins <-
  read_csv("https://tidymodels.org/start/models/urchins.csv") %>% 
  # Change the names to be a little more verbose
  setNames(c("food_regime", "initial_volume", "width")) %>% 
  # Factors are very helpful for modeling, so we convert one column
  mutate(food_regime = factor(food_regime, levels = c("Initial", "Low", "High")))

# Visualizing data
urchins

ggplot(urchins,
       aes(x = initial_volume, 
           y = width, 
           group = food_regime, 
           col = food_regime)) + 
  geom_point() + 
  geom_smooth(method = lm, se = FALSE) +
  scale_color_viridis_d(option = "plasma", end = .7)

# Fitting Linear Regression Model with Parsnip
lm_mod <- 
  linear_reg() %>% 
  set_engine("lm")

lm_fit <- 
  lm_mod %>% 
  fit(width ~ initial_volume * food_regime, data = urchins)
lm_fit

# Using Tidy to summarize results neatly
tidy(lm_fit)

# Dot and Whisker plot of results
tidy(lm_fit) %>% 
  dwplot(dot_args = list(size = 2, color = "black"),
         whisker_args = list(color = "black"),
         vline = geom_vline(xintercept = 0, colour = "grey50", linetype = 2))

# Using new starting point for prediction
new_points <- expand.grid(initial_volume = 20, 
                          food_regime = c("Initial", "Low", "High"))

mean_pred <- predict(lm_fit, new_data = new_points)
mean_pred

#### Using Bayesian Anaylsis method ####

# set the prior distribution
library(rstanarm)
prior_dist <- rstanarm::student_t(df = 1)

set.seed(123)

# make the parsnip model
bayes_mod <-   
  linear_reg() %>% 
  set_engine("stan", 
             prior_intercept = prior_dist, 
             prior = prior_dist) 

# train the model
bayes_fit <- 
  bayes_mod %>% 
  fit(width ~ initial_volume * food_regime, data = urchins)

print(bayes_fit, digits = 5)

tidy(bayes_fit, conf.int = TRUE)

############################ Pre processing Data ######################
