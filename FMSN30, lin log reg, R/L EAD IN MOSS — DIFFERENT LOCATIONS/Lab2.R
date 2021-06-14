library(ggplot2)
load("Pb_all.rda")
Pb.data <- Pb_all
# Number of observations at each location
summary(Pb.data)

# 2.A ####

# 2.A(a)
ggplot(data = Pb.data, aes(x = year, y = Pb)) +
  geom_point()

# 2.A(b)
Pb.data["year0"] = I(Pb.data["year"] - 1975)
Pb.data["logPb"] = log(Pb.data["Pb"])
ggplot(data = Pb.data, aes(x = year0, y = logPb)) +
  geom_point()
Pb.logmodel <- lm(logPb~year0, data = Pb.data[c("year0", "logPb")])

# 2.A(c)
confint(Pb.logmodel) # Smaller interval --> significant
summary(Pb.logmodel) # Pr(>|t|) <2e-16  (small) --> significant 
# t value = 95% significance interval beta1 = 0
# Pr(>|t|): prob of model if H0 = true
# t value: bigger the smaller prob for H0: beta1 = 0
# dofs?

# 2.A(d)
exp(predict(Pb.logmodel, newdata = data.frame(year0 = 2008-1975), interval = "prediction"))

exp(predict(Pb.logmodel, newdata = data.frame(year0 = 2008-1975), interval = "confidence"))



# 2.A(e)
Pb.lpred <- cbind(Pb.data,
                  fit = predict(Pb.logmodel),
                  conf = predict(Pb.logmodel, interval = "confidence"),
                  pred = predict(Pb.logmodel, interval = "prediction"))
Pb.lpred$e <- Pb.logmodel$residuals
lmax.e <- max(abs(Pb.lpred$e))
Pb.logelims <- c(-lmax.e, lmax.e)

# Plot error vs predicted
ggplot(data = Pb.lpred, 
       aes(x = fit, y = e)) +
  geom_point(size = 3) +
  geom_smooth() +
  geom_hline(yintercept = 0) +
  expand_limits(y = Pb.logelims) +
  xlab("Yhat") +
  ylab("Residual") +
  labs(tag = "A") +
  labs(title = "Residuals Predictions") +
  theme(text = element_text(size = 18))

# Q-Q plot
ggplot(data = Pb.lpred, aes(sample = e)) +
  geom_qq(size = 3) +
  geom_qq_line() +
  labs(tag = "C") +
  labs(title = "Normal Q-Q-plot of the residuals") +
  theme(text = element_text(size = 18))
#What is Q-Q plot

# 2.A(f)
# Plotting again for each region

# Error vs predicted plot for each region
ggplot(data = Pb.lpred, 
       aes(x = fit, y = e)) +
  geom_point(size = 3) +
  facet_wrap(~ region)+
  geom_smooth() +
  geom_hline(yintercept = 0) +
  expand_limits(y = Pb.logelims) +
  xlab("Yhat") +
  ylab("Residual") +
  labs(tag = "A") +
  labs(title = "Residuals vs x-values") +
  theme(text = element_text(size = 18))

# Q-Q plot for each region
ggplot(data = Pb.lpred, aes(sample = e)) +
  geom_qq(size = 3) +
  facet_wrap(~ region)+
  geom_qq_line() +
  labs(tag = "C") +
  labs(title = "Normal Q-Q-plot of the residuals") +
  theme(text = element_text(size = 18))



# 2.B ####

# 2.B(a)

ggplot(data = Pb.data, aes(x = year, y = Pb)) +
  geom_point()+
  facet_wrap(~ region)


# 2.B(b)
ggplot(data = Pb.data, aes(x = year, y = logPb)) +
  geom_point()+
  facet_wrap(~ region)


# 2.B(c)
Pb.logregionmodel <- lm(logPb~year0 + region, data = Pb.data[c("year0", "logPb", "region")])
summary(Pb.logregionmodel)

# 2.B(d)
Pb.data$region <- relevel(Pb.data$region, "Jamtland")
Pb.logregionmodel <- lm(logPb~year0 + region, data = Pb.data[c("year0", "logPb", "region")])

summary(Pb.logregionmodel)
exp(Pb.logregionmodel$coefficients)
exp(confint(Pb.logregionmodel))


# 2.B(e)
region1 <- "Jamtland"
exp(predict(Pb.logregionmodel, newdata = data.frame(year0 = 2008-1975, region = region1), interval = "confidence"))

exp(predict(Pb.logregionmodel, newdata = data.frame(year0 = 2008-1975, region = region1), interval = "prediction"))

# 2.B(f)
expcoff <- exp(Pb.logregionmodel$coefficients)
expconfint <- exp(confint(Pb.logregionmodel))

# 2.B(g)
exp(predict(Pb.logregionmodel, newdata = data.frame(year0 = 0, region = "Orebro"), interval = "confidence"))

# 2.B(h)
exp(predict(Pb.logregionmodel, newdata = data.frame(year0 = 2008-1975, region = "Orebro"), interval = "confidence"))

# 2.C ####

# 2.C(a)
summary(Pb.logregionmodel)

# 2.C(b)
anova(Pb.logmodel, Pb.logregionmodel)

# 2.C(c)
Pb.lpred$exp.fit <- exp(Pb.lpred$fit)
Pb.lpred$expconf.lwr <- exp(Pb.lpred$conf.lwr)
Pb.lpred$expconf.upr <- exp(Pb.lpred$conf.upr)
Pb.lpred$exppred.lwr <- exp(Pb.lpred$pred.lwr)
Pb.lpred$exppred.upr <- exp(Pb.lpred$pred.upr)


(
  plot.data <- 
    ggplot(data = Pb.lpred, aes(x = year0, y = Pb)) + 
    geom_point(size = 3) +
    facet_wrap(~ region) +
    xlab("Year - 1975") +
    ylab("Lead concentration (Pb)") +
    labs(title = "lead concentration vs year") +
    theme(text = element_text(size = 18)) +
    geom_line(aes(y = exp.fit), color = "#FD31F4", size = 1)+
    geom_ribbon(aes(ymin = expconf.lwr, ymax = expconf.upr), alpha = 0.2)+
    geom_line(aes(y = exppred.lwr),
              color = "#4C012E", linetype = "dashed", size = 1) +
    geom_line(aes(y = exppred.upr),
              color = "#4C012E", linetype = "dashed", size = 1)
)

(
  plot.data <- 
    ggplot(data = Pb.lpred, aes(x = year0, y = logPb)) + 
    geom_point(size = 3) +
    facet_wrap(~ region) +
    xlab("Year - 1975") +
    ylab("Lead concentration (Pb)") +
    labs(title = "lead concentration vs year") +
    theme(text = element_text(size = 18)) +
    geom_line(aes(y = fit), color = "red", size = 1)+
    geom_ribbon(aes(ymin = conf.lwr, ymax = conf.upr), alpha = 0.2)+
    geom_line(aes(y = pred.lwr),
              color = "red", linetype = "dashed", size = 1) +
    geom_line(aes(y = pred.upr),
              color = "red", linetype = "dashed", size = 1)
)

# 2.C(d)
Pb.lpred$expe <- exp(Pb.logmodel$residuals)
lmax.expe <- exp(max(abs(Pb.lpred$e)))
Pb.expelims <- exp(c(-lmax.e, lmax.e))


# Plot error vs predicted
ggplot(data = Pb.lpred, 
       aes(x = exp.fit, y = expe)) +
  geom_point(size = 3) +
  geom_smooth() +
  geom_hline(yintercept = 0) +
  expand_limits(y = Pb.expelims) +
  xlab("Yhat") +
  ylab("Residual") +
  labs(tag = "A") +
  labs(title = "Residuals Predictions") +
  theme(text = element_text(size = 18))

# Q-Q plot
ggplot(data = Pb.lpred, aes(sample = expe)) +
  geom_qq(size = 3) +
  geom_qq_line() +
  labs(tag = "C") +
  labs(title = "Normal Q-Q-plot of the residuals") +
  theme(text = element_text(size = 18))
#What is Q-Q plot

# 2.C(e)

# Plot error vs predicted
ggplot(data = Pb.lpred, 
       aes(x = exp.fit, y = expe)) +
  geom_point(size = 3) +
  facet_wrap(~ region) +
  geom_smooth() +
  geom_hline(yintercept = 0) +
  expand_limits(y = Pb.expelims) +
  xlab("Yhat") +
  ylab("Residual") +
  labs(tag = "A") +
  labs(title = "Residuals Predictions") +
  theme(text = element_text(size = 18))

# Q-Q plot
ggplot(data = Pb.lpred, aes(sample = expe)) +
  geom_qq(size = 3) +
  facet_wrap(~ region) +
  geom_qq_line() +
  labs(tag = "C") +
  labs(title = "Normal Q-Q-plot of the residuals") +
  theme(text = element_text(size = 18))
#What is Q-Q plot