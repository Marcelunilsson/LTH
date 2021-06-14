# Laboration 1
library(ggplot2)
load("Pb_Jamtland.rda")
Pb.data <- Pb_Jamtland
summary(Pb.data)
head(Pb.data)


# 1.A(a) Plot Pb against year
plot(Pb.data[c("year", "Pb")])


# 1.A(b) 
Pb.data["year0"] = I(Pb.data["year"] - 1975)
plot(Pb.data[c("year0", "Pb")], main = "Regression")

# 1.A(c) 
Pb.model <- lm(Pb~year0, data = Pb.data[c("year0", "Pb")])
(Pb.summary <- summary(Pb.model))
(beta <- unname(Pb.model$coefficients))
confint(Pb.model)
Pb.summary$coefficients

# 1.A(d)
beta[1]+beta[2]*(1975-1975)


# 1.A(e)
beta[2]

# 1.A(f)
predict(Pb.model, newdata = data.frame(year0 = 2008-1975), interval = "confidence")

# 1.A(g)
predict(Pb.model, newdata = data.frame(year0 = 2008-1975), interval = "prediction")

# 1.A(h)
Pb.pred <- cbind(Pb.data,
                 fit = predict(Pb.model),
                 conf = predict(Pb.model, interval = "confidence"),
                 pred = predict(Pb.model, interval = "prediction"))

(
  plot.data <- 
    ggplot(data = Pb.pred, aes(x = year0, y = Pb)) + 
    geom_point(size = 3) +
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

# 1.A(i)
head(Pb.pred$e <- Pb.model$residuals)
(max.e <- max(abs(Pb.pred$e)))
(Pb.elims <- c(-max.e, max.e))

ggplot(data = Pb.pred, 
       aes(x = year0, y = e)) +
  geom_point(size = 3) +
  geom_smooth() +
  geom_hline(yintercept = 0) +
  expand_limits(y = Pb.elims) +
  xlab("Yhat") +
  ylab("Residual") +
  labs(tag = "A") +
  labs(title = "Residuals vs x-values") +
  theme(text = element_text(size = 18))

# 1.A(j)
ggplot(data = Pb.pred, aes(sample = e)) +
  geom_qq(size = 3) +
  geom_qq_line() +
  labs(tag = "C") +
  labs(title = "Normal Q-Q-plot of the residuals") +
  theme(text = element_text(size = 18))

ggplot(data = Pb.pred, aes(x = e)) +
  geom_histogram(bins = 10) +
  xlab("Residuals") +
  labs(title = "Histogram of residuals") +
  theme(text = element_text(size = 18))

#------------------------------------------------------------------------------
# Clear env
#remove(list = ls())
#------------------------------------------------------------------------------

# 1.B(a)
print("Would sugest a exponential model, logtransform of Y")

# 1.B(b)
ggplot(data = Pb.data, aes(x = year0, y = log(Pb))) +
  geom_point() +
  expand_limits(x = c(20, 50))

# 1.B(c)
Pb.data["lPb"]  = log(Pb.data["Pb"])
Pb.logmodel <- lm(lPb~year0, data = Pb.data[c("year0", "lPb")])
(Pb.logsummary <- summary(Pb.logmodel))
(lbeta <- unname(Pb.logmodel$coefficients))
confint(Pb.logmodel)
Pb.logsummary$coefficients


# 1.B(d)
lbeta[1]

# 1.B(e)
lbeta[2]

# 1.B(f)
predict(Pb.logmodel, newdata = data.frame(year0 = 2008-1975), interval = "confidence")

# 1.B(g)
predict(Pb.logmodel, newdata = data.frame(year0 = 2008-1975), interval = "prediction")

# 1.B(h)
Pb.lpred <- cbind(Pb.data,
                 fit = predict(Pb.logmodel),
                 conf = predict(Pb.logmodel, interval = "confidence"),
                 pred = predict(Pb.logmodel, interval = "prediction"))

(
  plot.data <- 
    ggplot(data = Pb.lpred, aes(x = year0, y = lPb)) + 
    geom_point(size = 3) +
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

# 1.B(i)
head(Pb.lpred$e <- Pb.logmodel$residuals)
(lmax.e <- max(abs(Pb.lpred$e)))
(Pb.logelims <- c(-lmax.e, lmax.e))

ggplot(data = Pb.lpred, 
       aes(x = year0, y = e)) +
  geom_point(size = 3) +
  geom_smooth() +
  geom_hline(yintercept = 0) +
  expand_limits(y = Pb.elims) +
  xlab("Yhat") +
  ylab("Residual") +
  labs(tag = "A") +
  labs(title = "Residuals vs x-values") +
  theme(text = element_text(size = 18))

ggplot(data = Pb.lpred, aes(sample = e)) +
  geom_qq(size = 3) +
  geom_qq_line() +
  labs(tag = "C") +
  labs(title = "Normal Q-Q-plot of the residuals") +
  theme(text = element_text(size = 18))

ggplot(data = Pb.lpred, aes(x = e)) +
  geom_histogram(bins = 10) +
  xlab("Residuals") +
  labs(title = "Histogram of residuals") +
  theme(text = element_text(size = 18))


#------------------------------------------------------------------------------
# Clear env
#remove(list = ls())
#------------------------------------------------------------------------------

# 1.C(a)
print("ln(Pb) = beta0 + beta1^(year-1975)")
print("Pb = exp(beta0) * exp(beta1)^(year-1975)")
Pb.lpred$exp.fit <- exp(Pb.lpred$fit)
Pb.lpred$expconf.lwr <- exp(Pb.lpred$conf.lwr)
Pb.lpred$expconf.upr <- exp(Pb.lpred$conf.upr)
Pb.lpred$exppred.lwr <- exp(Pb.lpred$pred.lwr)
Pb.lpred$exppred.upr <- exp(Pb.lpred$pred.upr)
Pb.lpred


# 1.C(b)
(a <- exp(Pb.logsummary$coefficients[1]))
(b <- exp(Pb.logsummary$coefficients[2]))
(Ia <- exp(confint(Pb.logmodel)[1, ]))
(Ib <- exp(confint(Pb.logmodel)[2, ]))


# 1.C(c)
print(a)

# 1.C(d)
print(b)

# 1.C(e)
exp(predict(Pb.logmodel, newdata = data.frame(year0 = 2008-1975), interval = "confidence"))

# 1.C(f)
exp(predict(Pb.logmodel, newdata = data.frame(year0 = 2008-1975), interval = "prediction"))

# 1.c(g)
(
  plot.data <- 
    ggplot(data = Pb.lpred, aes(x = year0, y = Pb)) + 
    geom_point(size = 3) +
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


# 1.C(h)
(
  plot.data <- 
    ggplot(data = Pb.lpred, aes(x = year, y = Pb)) + 
    geom_point(size = 3) +
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

