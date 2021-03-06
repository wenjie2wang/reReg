#############################################################################################
## load packages and data readmission
#############################################################################################

library(parallel)
library(reReg)
library(reda)
library(gridExtra)
library(xtable)
data(readmission, package = "frailtypack")

R0 <- function(x) log(1 + x) / .5
H0 <- function(x) log(1 + x) / 8

fm <- reSurv(Time, id, event, status) ~ x1 + x2    

meanOut <- function(dat, na.rm = TRUE) {
    dat[which(dat %in% boxplot(dat, plot = FALSE)$out)] <- NA
    dat <- dat[complete.cases(dat)]
    mean(dat, na.rm = na.rm)
}

sdOut <- function(dat, na.rm = TRUE) {
    dat[which(dat %in% boxplot(dat, plot = FALSE)$out)] <- NA
    dat <- dat[complete.cases(dat)]
    sd(dat, na.rm = na.rm)
}

varOut <- function(dat, na.rm = TRUE) {
    dat[which(dat %in% boxplot(dat, plot = FALSE)$out)] <- NA
    dat <- dat[complete.cases(dat)]
    var(dat, na.rm = na.rm)
}

varMatOut <- function(dat, na.rm = TRUE) {
    dat[which(dat %in% boxplot(dat, plot = FALSE)$out)] <- NA
    dat <- dat[complete.cases(dat),]
    var(dat, na.rm = na.rm)
}

## ------------------------------------------------------------------------------------------
## checking reSurv
## ------------------------------------------------------------------------------------------
attach(readmission)
reSurv(t.stop)
reSurv(t.stop, id)
reSurv(t.stop, id, event)
reSurv(t.stop, id, event, death)

reSurv(t.start, t.stop)
reSurv(t.start, t.stop, id)
reSurv(t.start, t.stop, id, event)
reSurv(t.start, t.stop, id, event, death)

reSurv(t.stop)$reDF
reSurv(t.start, t.stop)$reDF

identical(reSurv(t.stop)$reTb, reSurv(t.start, t.stop)$reTb) # FALSE
identical(reSurv(t.stop, id)$reTb, reSurv(t.start, t.stop, id)$reTb) # TRUE
identical(reSurv(t.stop, id, event)$reTb, reSurv(t.start, t.stop, id, event)$reTb) # TRUE
identical(reSurv(t.stop, id, event, death)$reTb, reSurv(t.start, t.stop, id, event, death)$reTb) # TRUE

reSurv(time1 = t.start, time2 = t.stop, id = id, event = event, status = death)
reSurv(time1 = t.stop, id = id, event = event, status = death)

detach(readmission)

## ------------------------------------------------------------------------------------------
## checking plotEvents
## ------------------------------------------------------------------------------------------
reObj <- with(readmission, reSurv(t.stop, id, event, death))

plot(reObj)
plot(reObj, xlab = "User X", ylab = "User Y", main = "User title")
plot(reObj, control = list(xlab = "User X", ylab = "User Y", main = "User title"))

plot(reObj, order = FALSE)
plot(reObj, order = FALSE, xlab = "User X", ylab = "User Y", main = "User title")
plot(reObj, order = FALSE, control = list(xlab = "User X", ylab = "User Y", main = "User title"))

plotEvents(reSurv(t.stop, id, event, death) ~ 1, data = readmission)
plotEvents(reSurv(t.stop, id, event, death) ~ 1, data = readmission,
           xlab = "User X", ylab = "User Y", main = "User title")
           
plotEvents(reSurv(t.stop, id, event, death) ~ sex, data = readmission)
plotEvents(reSurv(t.stop, id, event, death) ~ sex, data = readmission,
           xlab = "User X", ylab = "User Y", main = "User title")           
plotEvents(reSurv(t.stop, id, event, death) ~ sex + chemo, data = readmission)
plotEvents(reSurv(t.stop, id, event, death) ~ sex + chemo, data = readmission,
           xlab = "User X", ylab = "User Y", main = "User title",
           control = list(terminal.name = "User terminal",
                          recurrent.name = "User event"))

## multiple event types
reObj <- with(readmission, reSurv(t.stop, id, event * sample(1:3, 861, TRUE), death))
plot(reObj)
plot(reObj, xlab = "User X", ylab = "User Y", main = "User title")
plot(reObj, control = list(xlab = "User X", ylab = "User Y", main = "User title"))
plot(reObj, xlab = "User X", ylab = "User Y", main = "User title",
     control = list(recurrent.name = "User event"))
plot(reObj, xlab = "User X", ylab = "User Y", main = "User title",
     control = list(recurrent.type = letters[1:3]))

plotEvents(reSurv(t.stop, id, event, death) ~ 1, data = readmission)
plotEvents(reSurv(t.stop, id, event, death) ~ sex, data = readmission,
           control = list(xlab = "User X", ylab = "User Y", main = "User title"))
plotEvents(reSurv(t.stop, id, event, death) ~ sex + chemo, data = readmission,
           xlab = "User X", ylab = "User Y", main = "User title")

set.seed(123)
fm <- reSurv(t.stop, id, event * sample(1:3, 861, TRUE), death) ~ sex + chemo
plotEvents(fm, data = readmission)
plotEvents(fm, data = readmission, xlab = "User X", ylab = "User Y", main = "User title",
           control = list(recurrent.type = letters[1:3]))

## ------------------------------------------------------------------------------------------
## checking plotCSM
## ------------------------------------------------------------------------------------------
reObj <- with(readmission, reSurv(t.stop, id, event, death))

plot(reObj, CSM = TRUE)
plot(reObj, CSM = TRUE, xlab = "User X", ylab = "User Y", main = "User title")
plot(reObj, CSM = TRUE, control = list(xlab = "User X", ylab = "User Y", main = "User title"))

plotCSM(reSurv(t.stop, id, event, death) ~ 1, data = readmission)
plotCSM(reSurv(t.stop, id, event, death) ~ sex, data = readmission)
plotCSM(reSurv(t.stop, id, event, death) ~ sex, data = readmission, onePanel = TRUE)

set.seed(123)
fm <- reSurv(t.stop, id, event * sample(1:3, 861, TRUE), death) ~ sex + chemo
plotCSM(fm, data = readmission)
plotCSM(fm, data = readmission, xlab = "User X", ylab = "User Y", main = "User title",
           control = list(recurrent.type = letters[1:3]))
plotCSM(fm, data = readmission, xlab = "User X", ylab = "User Y", main = "User title",
           control = list(recurrent.name = "Types", recurrent.type = letters[1:3]))

plotCSM(fm, data = readmission, recurrent.name = "Types", recurrent.type = letters[1:3])

plotCSM(fm, data = readmission, xlab = "User X", ylab = "User Y", main = "User title",
           control = list(recurrent.type = letters[1:3])) + ggplot2::theme(legend.position = "bottom")

## ------------------------------------------------------------------------------------------
## checking simulated data generator
## ------------------------------------------------------------------------------------------

simDat(1e4, c(1, -1), c(1, -1), indCen = TRUE, summary = TRUE)
simDat(1e4, c(1, -1), c(1, -1), indCen = FALSE, summary = TRUE)
simDat(1e4, c(1, -1), c(1, -1), indCen = TRUE, summary = TRUE, type = "am")
simDat(1e4, c(1, -1), c(1, -1), indCen = FALSE, summary = TRUE, type = "am")

simDat(1e4, c(1, -1), c(1, -1), indCen = TRUE, summary = TRUE, type = "sc")
simDat(1e4, c(1, -1), c(1, -1), indCen = FALSE, summary = TRUE, type = "sc")
simDat(1e4, c(0, 0), c(1, -1), indCen = TRUE, summary = TRUE, type = "sc")
simDat(1e4, c(0, 0), c(1, -1), indCen = FALSE, summary = TRUE, type = "sc")
simDat(1e4, c(1, -1), c(0, 0), indCen = TRUE, summary = TRUE, type = "sc")
simDat(1e4, c(1, -1), c(0, 0), indCen = FALSE, summary = TRUE, type = "sc")
simDat(1e4, c(1, 1), c(-1, -1), indCen = TRUE, summary = TRUE, type = "sc")
simDat(1e4, c(1, 1), c(-1, -1), indCen = FALSE, summary = TRUE, type = "sc")


## ------------------------------------------------------------------------------------------
## checking point esitmation
## ------------------------------------------------------------------------------------------

do <- function(n = 100, a = c(1, -1), b = c(1, -1), type = "cox", indCen = TRUE) {
    fm <- reSurv(Time, id, event, status) ~ x1 + x2
    B <- 200
    dat <- simDat(n = n, a = a, b = b, type = type, indCen = indCen)
    f1 <- reReg(fm, data = dat, se = "boot", B = 300)
    f2 <- reReg(fm, data = dat, method = "cox.HW", se = "resam", B = 300)
    invisible(capture.output(f3 <- reReg(fm, data = dat, method = "am.GL", se = "boot", B = 300)))
    f4 <- reReg(fm, data = dat, method = "am.XCHWY", se = "res", B = 300)
    f5 <- reReg(fm, data = dat, method = "sc.XCYH", se = "resam", B = 300)
    c(coef(f1), f1$alphaSE, f1$betaSE,
      coef(f2), f2$alphaSE, f2$betaSE,
      coef(f3), f3$alphaSE, f3$betaSE,
      coef(f4), f4$alphaSE, f4$betaSE,
      coef(f5), f5$alphaSE, f5$betaSE)
}


do <- function(n = 100, a = c(1, -1), b = c(1, -1), type = "cox", indCen = TRUE) {
    fm <- reSurv(Time, id, event, status) ~ x1 + x2
    B <- 500
    dat <- simDat(n = n, a = a, b = b, type = type, indCen = indCen)
    f2 <- reReg(fm, data = dat, method = "cox.HW", se = "resam", B = 300)
    c(coef(f2), f2$alphaSE, f2$betaSE)
}


cl <- makePSOCKcluster(8)
setDefaultCluster(cl)
clusterExport(NULL, c("do", "fm"))
clusterEvalQ(NULL, library(reReg))
f1 <- parSapply(NULL, 1:500, function(z) tryCatch(do(), error = function(e) rep(NA, 40)))
f2 <- parSapply(NULL, 1:500, function(z) tryCatch(do(indCen = FALSE), error = function(e) rep(NA, 40)))
f3 <- parSapply(NULL, 1:500, function(z) tryCatch(do(type = "am"), error = function(e) rep(NA, 40)))
f4 <- parSapply(NULL, 1:500, function(z)
    tryCatch(do(type = "am", indCen = FALSE), error = function(e) rep(NA, 40)))
f5 <- parSapply(NULL, 1:500, function(z)
    tryCatch(do(a = c(1, 1), b = c(-1, -1), type = "sc", indCen = TRUE),
             error = function(e) rep(NA, 40)))
f6 <- parSapply(NULL, 1:500, function(z)
    tryCatch(do(a = c(1, 1), b = c(-1, -1), type = "sc", indCen = FALSE),
             error = function(e) rep(NA, 40)))
stopCluster(cl)



## ------------------------------------------------------------------------------------------
## checking R examples
## ------------------------------------------------------------------------------------------
library(reReg)
set.seed(123)
dat <- simSC(500, c(-1, 1), c(-1, 1))

attach(dat)
reSurv(Time, id, event, status)
detach(dat)


set.seed(1)
dat <- simSC(100, c(-1, 1), c(-1, 1), type = "am")
(fit <- reReg(reSurv(Time, id, event, status) ~ x1 + x2, 
         data = dat, method = "am.XCHWY", se = "resampling", B = 20))
summary(fit)

set.seed(1)
dat <- simSC(100, c(-1, 1), c(-1, 1), type = "sc")
(fit <- reReg(reSurv(Time, id, event, status) ~ x1 + x2, 
         data = dat, method = "sc.XCYH", se = "resampling", B = 20))
summary(fit)

set.seed(1)
dat <- simSC(30, c(-1, 1), c(-1, 1))
reObj <- reSurv(Time, id, event, status)

plot(reObj)
plot(reObj, order = FALSE)
plot(reObj, control = list(xlab = "User xlab", ylab = "User ylab", main = "User title"))

set.seed(1)
reObj2 <- with(dat, reSurv(Time, id, event * sample(1:3, 203, TRUE), status))
plot(reObj2)

plot(reObj, CSM = TRUE)


set.seed(1)
dat <- simSC(30, c(-1, 1), c(-1, 1))
plotEvents(reSurv(Time, id, event, status) ~ 1, data = dat)
plotEvents(reSurv(Time, id, event, status) ~ x1, data = dat)
dat$x3 <- ifelse(dat$x2 < 0, "x2 < 0", "x2 > 0")
plotEvents(reSurv(Time, id, event, status) ~ x1 + x3, data = dat)
plotEvents(reSurv(Time, id, event * sample(1:3, 203, TRUE), status) ~ x1, data = dat)

plotCSM(reSurv(Time, id, event, status) ~ 1, data = dat)
plotCSM(reSurv(Time, id, event, status) ~ x1, data = dat)
plotCSM(reSurv(Time, id, event, status) ~ x1, data = dat, onePanel = TRUE)



set.seed(1)
dat <- simSC(50, c(-1, 1), c(-1, 1))
fit <- reReg(reSurv(Time, id, event, status) ~ x1 + x2, data = dat, method = "cox.HW")
plot(fit, baseline = "rate")
plot(fit, baseline = "rate", xlab = "Time (days)")


set.seed(1)
dat <- simSC(50, c(-1, 1), c(-1, 1))
fit <- reReg(reSurv(Time, id, event, status) ~ x1 + x2, data = dat,
             method = "am.XCHWY", se = "resampling", B = 20)
plot(fit)
plotRate(fit)
plotRate(fit, xlab = "User xlab", ylab = "User ylab", main = "User title")
plotHaz(fit)
