library(ggplot2)
library(plyr)
load("Pb_all.rda")
Pb.data <- Pb_all
# Number of observations at each location

# 3.A ####


# 3.A(a) 
# Models
Pb.linmod <- lm(Pb ~ I(year - 1975), data = Pb.data[c("year", "Pb")])
Pb.logmod <- lm(log(Pb) ~ I(year - 1975), data = Pb.data[c("year", "Pb")])

# Predictions
Pb.linmod.pred <- cbind(Pb.data, fit = predict(Pb.linmod), r = rstudent(Pb.linmod))
Pb.logmod.pred <- cbind(Pb.data, fit = predict(Pb.logmod), r = rstudent(Pb.logmod))

# Leverage v_ii
Pb.linmod.pred$v <- influence(Pb.linmod)$hat
Pb.logmod.pred$v <- influence(Pb.logmod)$hat

# Plot leverage for linear model
ggplot(cbind(Pb.linmod.pred), aes(x = I(year -1975), y = v)) +
  geom_point(size = 3) +
  geom_hline(yintercept = 1/nrow(Pb.data)) +
  geom_hline(yintercept = 2*(length(Pb.linmod$coefficients)+1)/nrow(Pb.data), 
             color = "red") +
  labs(title = "Pb: leverage vs year -1975") +
  labs(caption = "y = 1/n (black) and 2(p+1)/n (red)") +
  theme(text = element_text(size = 18))

# Plot leverage for logarithmic model
ggplot(cbind(Pb.logmod.pred), aes(x = I(year -1975), y = v)) +
  geom_point(size = 3) +
  geom_hline(yintercept = 1/nrow(Pb.data)) +
  geom_hline(yintercept = 2*(length(Pb.logmod$coefficients)+1)/nrow(Pb.data), 
             color = "red") +
  labs(title = "Pb: leverage vs year -1975") +
  labs(caption = "y = 1/n (black) and 2(p+1)/n (red)") +
  theme(text = element_text(size = 18))


#Is there any difference in the leverage between the two models? Why/why not? 
# No difference v_ii is only X-dependant and we have log(y)
# 1975 and 1980
#Any years where the observations have a high leverage?
#Which year would the leverage be at its minimum?


# 3.A(b) 


Pb.data$region <- relevel(Pb.data$region, "Norrbotten") # mzq gives region
Pb.logregionmodel <- lm(log(Pb)~I(year-1975) + region, data = Pb.data[c("year", "Pb", "region")])

Pb.logregionmodel.pred <- cbind(
  Pb.data, 
  fit = predict(Pb.logregionmodel),
  r = rstudent(Pb.logregionmodel))

# leverage
Pb.logregionmodel.pred$v <- influence(Pb.logregionmodel)$hat

ggplot(cbind(Pb.logregionmodel.pred), aes(x = I(year-1975), y = v, color = region)) +
  geom_jitter(width = 1) +
  geom_hline(yintercept = 1/nrow(Pb.data)) +
  geom_hline(yintercept = 2*(length(Pb.logregionmodel$coefficients)+1)/nrow(Pb.data), 
             color = "red") +
  labs(title = "Leverage vs year") +
  labs(caption = "y = 1/n (black) and 2(p+1)/n (red)") +
  theme(text = element_text(size = 18))+
  expand_limits(y = 0)

#Any patterns of large leverage? 
# Older measurement --> higher leverage
#Why are the regions ordered as they are? 
count(Pb.data, "region")
# more datapoints --> less leverage per point

# 3.A(c) 

# plot residuals
ggplot(Pb.logregionmodel.pred, aes(x = fit, y = r)) +
  geom_point(size = 3) +
  geom_hline(yintercept = c(-2, 0, 2)) +
  geom_hline(yintercept = c(-3, 3), linetype = 2) +
  geom_smooth() +
  labs(title = "Pb: residuals vs fitted values") +
  xlab("fitted values (log(Pb))") +
  ylab("studentized residuals") +
  theme(text = element_text(size = 18))

#Are there any trends in the residuals? 
# Looks quite evenly distributed, with a little more variance for
#   large and small values of log(Pb)
#Are there any unpleasantly large residuals?
# There are 3-4 of them



# 3.A(d) 
ggplot(Pb.logregionmodel.pred, aes(x = fit, y = r)) +
  geom_point(size = 3) +
  geom_hline(yintercept = c(-2, 0, 2)) +
  geom_hline(yintercept = c(-3, 3), linetype = 2) +
  geom_smooth() +
  labs(title = "Pb: residuals vs fitted values") +
  xlab("fitted values (log(Pb))") +
  ylab("studentized residuals") +
  theme(text = element_text(size = 18))+
  facet_wrap(~region)

# Are there any trends in the residuals in any of the regions? 
# Regions with less data points have worse variance in their residuals
# What might that indicate?
# That we need more data points for these regions and 
# that this model might not fit all regions equally well

# 3.A(e) 

ggplot(Pb.logregionmodel.pred, aes(x = fit, y = sqrt(abs(r)))) +
  geom_point(size = 3) +
  geom_hline(yintercept = c(sqrt(qnorm(0.75)), sqrt(2))) +
  geom_hline(yintercept = sqrt(3), linetype = 2) +
  geom_smooth() +
  labs(title = "Pb: sqrt(|r*|) vs y-hat") +
  xlab("fitted values (log(Pb))") +
  ylab("sqrt(|r*|)") +
  theme(text = element_text(size = 18))+
  expand_limits(y = 0)+
  facet_wrap(~region)
# Are there any unpleasant trends in the residual 
# variability in any of the regions?

# Örebro har stor varians i mitten

# 3.A(f) 

# Cook's D
Pb.logregionmodel.pred$D <- cooks.distance(Pb.logregionmodel)
head(Pb.logregionmodel.pred)  


# Plot against r*
(f1.Pb <- length(Pb.logregionmodel$coefficients))
(f2.Pb <- Pb.logregionmodel$df.residual)
(Pb.logregionmodel.pred$cooklimit <- qf(0.5, f1.Pb, f2.Pb))
ggplot(Pb.logregionmodel.pred, aes(fit, D)) + 
  geom_point(size = 3) +
  #geom_hline(yintercept = Pb.logregionmodel.pred$cooklimit, color = "red") +
  geom_hline(yintercept = 4/nrow(Pb.logregionmodel.pred), linetype = 2, color = "red") +
  xlab("Fitted values") +
  ylab("D_i") +
  labs(title = "Pb: Cook's D") +
  labs(caption = "4/n (dashed), F_0.5, p+1, n-(p+1) (solid)") +
  theme(text = element_text(size = 18))+
  facet_wrap(~region)

# Are there any observations that have had an substantially 
# larger influence on the estimates than the rest? 
# yes especially in västra götaland
Pb.logregionmodel.pred[Pb.logregionmodel.pred$D > 0.010, ]
# observation 1186 is the largest outlier by far

# Were they also observations with high leverage? 
Pb.logregionmodel.pred[Pb.logregionmodel.pred$v > 0.010, ]
# observation 1186 does not have the largest leverage

# Were they also observations with large residuals?
Pb.logregionmodel.pred[Pb.logregionmodel.pred$r > 2.6, ]
# observation 1186 have a large residual

# 3.A(g) 

# DFBETAS
head(dfbetas(Pb.logregionmodel))
Pb.logregionmodel.pred$df1 <- dfbetas(Pb.logregionmodel)[, "I(year - 1975)"]


#dfbetas for beta_1:
ggplot(Pb.logregionmodel.pred, aes(x = I(year-1975), y = df1)) +
  geom_point(size = 2) +
  geom_hline(yintercept = 0) +
  ylab("DFBETAS_1(i)") +
  xlab("Fitted values") +
  labs(title = "Pb: DFBETAS_1: impact on the I(year - 1975)") +
  labs(caption = "y = sqrt(F_0.5) and 2/sqrt(n)") +
  theme(text = element_text(size = 18))+
  facet_wrap(~region)

# Did the influential points in 3.A(f) in Orebro have a large ¨
# influence on the estimate of the rate of decline?

# a strong Nja

# Did the one in Västra Götaland?

# We can see that observation 1186 is here spöking again.


# 3.A(h) 
I.retard <- which(Pb.logregionmodel.pred$D > 0.020)

ggplot(data = Pb.data, aes(x = year, y = Pb)) +
  geom_point()+
  geom_point(data = Pb.data[I.retard, ], 
             color = "red", size = 3, shape = 24) +
  facet_wrap(~ region)

#Does it seem logical that it had a large influence on the estimated rate of
#decline?

# Yes


# 3.B ####

# 3.B(a) 
Pb.logyearregionmodel <- lm(log(Pb)~I(year-1975)*region, data = Pb.data[c("year", "Pb", "region")])

anova(Pb.logyearregionmodel, Pb.logregionmodel)

Pb.logyearregionmodel.pred <- cbind(
  Pb.data, 
  fit = predict(Pb.logregionmodel),
  r = rstudent(Pb.logregionmodel))

# leverage
Pb.logyearregionmodel.pred$v <- influence(Pb.logregionmodel)$hat

ggplot(Pb.logyearregionmodel.pred, aes(x = fit, y = r)) +
  geom_point(size = 3) +
  geom_hline(yintercept = c(-2, 0, 2)) +
  geom_hline(yintercept = c(-3, 3), linetype = 2) +
  geom_smooth() +
  labs(title = "Pb: residuals vs fitted values") +
  xlab("fitted values (log(Pb))") +
  ylab("studentized residuals") +
  theme(text = element_text(size = 18))+
  facet_wrap(~region)

# 3.B(b)
summary(Pb.logmod)
summary(Pb.logregionmodel)
summary(Pb.logyearregionmodel)

AIC(Pb.logmod,Pb.logregionmodel ,Pb.logyearregionmodel )
BIC(Pb.logmod,Pb.logregionmodel ,Pb.logyearregionmodel )
