

#******************************************************
#
#					Session 5
#				
#				Principal Components
#
#******************************************************


#***********************************************************
#
#			Install and load the necessary libraries
#
#***********************************************************

# Load ggplot2 and psych libraries
library(ggplot2)
library(psych)

# libraries needed for ggbiplot and loadingsplot in PCAplots.R
library(data.table)
library(plyr)
library(scales)
library(grid)
library(ggpubr)

#***********************************************************
#
#			Load and format the data
#
#***********************************************************

traindir <- "E:/UVA/学术/SYS6021/Rsession_data/TrainData"
sourcedir <-"E:/UVA/学术/SYS6021/Rsession_code/PCA"

# Source AccidentInput
setwd(sourcedir)
source("AccidentInput.R")
source("PCAplots.R")

# you should have two data structures in working memory
# First - a list of data frames for each year of accident data

acts <- file.inputl(traindir)

# Next a data frame with all accidents from all years from 2001 - 2019

# the combined data frame

totacts <- combine.data(acts)

#***********************************************************
#
#			Get the extreme accident data
#
#***********************************************************

# For ACCDMG
dmgbox <- ggplot(totacts, aes(y=ACCDMG)) + geom_boxplot()
dmgbox

# find only those above the upper whisker
upper <- ggplot_build(dmgbox)$data[[1]]$ymax
xdmg <- totacts[totacts$ACCDMG > upper,]

# For Casualties (TOTINJ + TOTKLD)

xdmg$Casualties <- xdmg$TOTINJ + xdmg$TOTKLD

# Remove 9/11
xdmg <- xdmg[-181,]

#***********************************************************
#
#			Remove duplicates
#
#***********************************************************

# Remove duplicates
xdmgnd <- xdmg[!(duplicated(xdmg[, c("INCDTNO", "YEAR", "MONTH", "DAY", "TIMEHR", "TIMEMIN")])),]

#Reset rownames (observation #s) for sequential numbering- otherwise they will remain the #s from totacts

rownames(xdmgnd) <- NULL

#***********************************************************
#
#		Principal Components Analysis
#
#***********************************************************
?prcomp


# Principal Components of metrics for extreme accidents

xdmgnd.pca <- prcomp(xdmgnd[,c("CARSDMG","EQPDMG","TRKDMG","ACCDMG", "TOTKLD", "TOTINJ")])
#head(xdmgnd.pca)
#***********************************************************
#
#		Biplot
#
#***********************************************************

# View the data in the first 2 PCs

biplot(xdmgnd.pca, main="Biplot of Extreme Accident Metrics")

# Using ggbiplot

ggbiplot(xdmgnd.pca, varname.size = 5, labels=row(xdmgnd)[,1])
ggbiplot(xdmgnd.pca, varname.size = 5, labels=row(xdmgnd)[,1], plot.obs=FALSE)
ggbiplot(xdmgnd.pca, varname.size = 5, labels=row(xdmgnd)[,1], plot.obs=FALSE, 
         xlim=c(-0.3,2), ylim=c(-0.7,0.7))

#***********************************************************
#
#		Scree plot and cumulative variance
#
#***********************************************************

scree.cov <- ggscreeplot(xdmgnd.pca)
scree.cov$var
scree.cov$plot

# Cumulative variance
cum.cov <- cumplot(xdmgnd.pca)
cum.cov$cumvar
cum.cov$plot

#***********************************************************
#
#		Loadings plots
#
#***********************************************************

# Loadings in the first 2 PCs

loadplot.cov <- loadingsplot(xdmgnd.pca)
loadplot.cov$loadings
loadplot.cov$plot


#***********************************************************
#
#		Principal Components with the Correlation Matrix	
#
#***********************************************************


# Principal Components with the Correlation Matrix

xdmgnd.pca.corr <- prcomp(xdmgnd[,c("CARSDMG","EQPDMG", "TRKDMG","ACCDMG", "TOTKLD", "TOTINJ")], scale = T)


#***********************************************************
#
#		Biplot Comparison
#
#***********************************************************

# View data in the first 2 PCs

par(mfrow=c(1,2))
biplot(xdmgnd.pca, main="Biplot with Covariance Matrix")
biplot(xdmgnd.pca.corr, main="Biplot with Correlation Matrix")
par(mfrow=c(1,1))

# With ggbiplot
cov_biplot <- ggbiplot(xdmgnd.pca, varname.size = 5, labels=row(xdmgnd)[,1])
corr_biplot <- ggbiplot(xdmgnd.pca.corr, varname.size = 5, labels=row(xdmgnd)[,1])
ggarrange(cov_biplot, corr_biplot, ncol=2, nrow=1)

# Just variable vectors
cov_biplot <- ggbiplot(xdmgnd.pca, varname.size = 5, labels=row(xdmgnd)[,1],
                       plot.obs=FALSE, xlim=c(-0.3,2), ylim=c(-0.7,0.7))
corr_biplot <- ggbiplot(xdmgnd.pca.corr, varname.size = 5, labels=row(xdmgnd)[,1],
                        plot.obs=FALSE, xlim=c(-0.3,2.5), ylim=c(-1.5,2))
ggarrange(cov_biplot, corr_biplot, ncol=2, nrow=1)


#***********************************************************
#
#		Scree plot and cumulative variance comparison
#
#***********************************************************

cov_scree <- ggscreeplot(xdmgnd.pca)
corr_scree <- ggscreeplot(xdmgnd.pca.corr)

corr_scree$var

ggarrange(cov_scree$plot, corr_scree$plot, ncol=2, nrow=1)

# Cumulative variance

cov_cumsum <- cumplot(xdmgnd.pca)
corr_cumsum <- cumplot(xdmgnd.pca.corr)

corr_cumsum$cumvar

ggarrange(cov_cumsum$plot, corr_cumsum$plot, ncol=2, nrow=1)

#***********************************************************
#
#		Loadings plots comparison
#
#***********************************************************

loadplot.corr <- loadingsplot(xdmgnd.pca.corr)
loadplot.corr$loadings

ggarrange(loadplot.cov$plot, loadplot.corr$plot, ncol=2, nrow=1)


# 1st column is when using covariance matrix, 2nd when using correlation matrix


#***********************************************************
#
#		Possible predictors of damage	
#
#***********************************************************

# SPM
pairs.panels(xdmgnd[,c("ACCDMG", "TRNSPD", "CARS", "TIMEHR", "TEMP")])

# PCA

pred.pca <- prcomp(xdmgnd[,c("ACCDMG", "TRNSPD", "CARS", "TIMEHR", "TEMP")], scale = T )

biplot(pred.pca)

ggbiplot(pred.pca, varname.size = 5, labels=row(xdmgnd)[,1])

# Remove outlier

xdmgnd_no <- xdmgnd[-c(5251),]
rownames(xdmgnd_no) <- NULL
pred_no.pca <- prcomp(xdmgnd_no[,c("ACCDMG", "TRNSPD", "CARS", "TIMEHR", "TEMP")], scale = T )

biplot(pred_no.pca)

# gg biplot

ggbiplot(pred_no.pca, varname.size = 5, labels=row(xdmgnd_no)[,1])

# Do your conclusions change?

# Remove cluster of outliers

xdmgnd_no <- xdmgnd[-c(5251,5252,5956,7211,5955,7212,4615,6256,5608),]
rownames(xdmgnd_no) <- NULL
pred_no.pca <- prcomp(xdmgnd_no[,c("ACCDMG", "TRNSPD", "CARS", "TIMEHR", "TEMP")], scale = T )

biplot(pred_no.pca)

# gg biplot

ggbiplot(pred_no.pca, varname.size = 5, labels=row(xdmgnd_no)[,1])

