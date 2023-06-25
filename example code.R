# Species name ####
species <- c('Gryllodes_sigillatus', 'Homoeoxipha_lycoides', 'Loxoblemmus_appendicularis',
             'Tarbinskiellus_portentosus', 'Teleogryllus_mitratus', 'Teleogryllus_occipitalis')

# plot chirps' sound waves
par(mfrow = c(3, 2))
library(tuneR)
for (i in species){
  path <- paste("~/exampledata", i, sep = '')
  setwd(path)
  chirp <- readWave(list.files()[1])
  plot(chirp)
  title(i)
}
par(mfrow = c(1, 1))

# Define function to extract MFCC ####
extract.mfcc <- function(target, show.chirp){
  path <- paste("~/exampledata", target, sep = '')
  setwd(path)
  num.file <- length(list.files())
  
  if(target == 'Gryllodes_sigillatus'){genus <- 'Gryllodes'}
  else if (target == 'Homoeoxipha_lycoides'){genus <- 'Homoeoxipha'}
  else if (target == 'Loxoblemmus_appendicularis'){genus <- 'Loxo_ap'}
  else if (target == 'Tarbinskiellus_portentosus'){genus <- 'Tarbin'}
  else if (target == 'Teleogryllus_mitratus'){genus <- 'T_mitratus'}
  else if (target == 'Teleogryllus_occipitalis'){genus <- 'T_occ'}
  
  require(tuneR)
  result <- NULL
  for(i in 1:num.file){
    path <- paste(genus, i, ".wav", sep = '')
    Song <- readWave(file = path)
    mfcc <- melfcc(Song, numcep = 13, usecmp = F, fbtype = 'mel',
                   wintime = 0.025)
    result <- as.data.frame(rbind(result, mfcc))
  }
  return(result)
}

Gryllodes <- extract.mfcc(target = 'Gryllodes_sigillatus')
Homoeoxipha <- extract.mfcc(target = 'Homoeoxipha_lycoides')
Loxo_ap <- extract.mfcc(target = 'Loxoblemmus_appendicularis')
Tarbin <- extract.mfcc(target = 'Tarbinskiellus_portentosus')
T_mitratus <- extract.mfcc(target = 'Teleogryllus_mitratus')
T_occ <- extract.mfcc(target = 'Teleogryllus_occipitalis')

# Use PCA to visualize MFCC of data ####
my.pca <- prcomp(whole.data, center = T, scale. = T)

library(ggbiplot)
groups <- c(rep('Gryllodes', nrow(Gryllodes)), rep('Homoeoxipha', nrow(Homoeoxipha)),
            rep('Loxo_ap', nrow(Loxo_ap)), rep('Tarbin', nrow(Tarbin)),
            rep('T_mitratus', nrow(T_mitratus)), rep('T_occ', nrow(T_occ)))
ggbiplot(my.pca, ellipse = T, groups = groups, var.axes = F) +
  theme_bw() + xlab('PC1') + ylab('PC2')

# Dataset preparation ####
label <- factor(as.numeric(gsub("Gryllodes", 1, 
                                gsub("Homoeoxipha", 2, 
                                     gsub('Loxo_ap', 3, 
                                          gsub('Tarbin', 4,
                                               gsub('T_mitratus', 5, 
                                                    gsub('T_occ', 6, groups))))))))

each.num <- nrow(Gryllodes)
ratio <- 0.8
train.num <- round(each.num*ratio, 0)
train.ind <- c()
test.ind <- c()
for (i in 1:length(species)){
  temp.train.ind <- (each.num*(i - 1) + 1):(each.num*i - each.num*(1 - ratio))
  train.ind <- c(train.ind, temp.train.ind)
  temp.test.ind <- (each.num*i - (each.num*(1 - ratio)) + 1):(each.num*i)
  test.ind <- c(test.ind, temp.test.ind)
}

train.x <- whole.data[train.ind, ]
train.y <- label[train.ind]
test.x <- whole.data[test.ind, ]
test.y <- label[test.ind]

# Build classifiers ####
# MLR ####
# Multinomial logistic regression #
data.mlr.dt <- data.frame(train.x, train.y)
col.label <- c('cep.1', 'cep.2', 'cep.3', 'cep.4', 'cep.5', 'cep.6',
               'cep.7', 'cep.8', 'cep.9', 'cep.10', 'cep.11', 'cep.12',
               'cep.13', 'species')
colnames(data.mlr.dt) <- col.label

library(nnet)
fit.logi <- multinom(species ~. , data = data.mlr.dt, maxit = 200)
summary(fit.logi)

train.x.mlr.dt <- train.x
test.x.mlr.dt <- test.x
colnames(train.x.mlr.dt) <- colnames(test.x.mlr.dt) <- col.label[-14]

pred.train.mlr <- predict(fit.logi, train.x.mlr.dt, type = "class")
pred.test.mlr <- predict(fit.logi, test.x.mlr.dt, type = "class")
train.cm.mlr <- table(real = train.y, pred = pred.train.mlr)
test.cm.mlr <- table(real = test.y, pred = pred.test.mlr)
train.acc.mlr <- sum(diag(train.cm.mlr))/sum(train.cm.mlr)
test.acc.mlr <- sum(diag(test.cm.mlr))/sum(test.cm.mlr)
all.acc.mlr <- (sum(diag(train.cm.mlr)) + sum(diag(test.cm.mlr)))/(sum(train.cm.mlr) + sum(test.cm.mlr))


# DT ####
library(rpart)
fit.dt <- rpart(species ~. , data = data.mlr.dt)

pred.train.dt <- predict(fit.dt, train.x.mlr.dt, type = "class")
pred.test.dt <- predict(fit.dt, test.x.mlr.dt, type = "class")
train.cm.dt <- table(real = train.y, pred = pred.train.dt)
test.cm.dt <- table(real = test.y, pred = pred.test.dt)
train.acc.dt <- sum(diag(train.cm.dt))/sum(train.cm.dt)
test.acc.dt <- sum(diag(test.cm.dt))/sum(test.cm.dt)
all.acc.dt <- (sum(diag(train.cm.dt)) + sum(diag(test.cm.dt)))/(sum(train.cm.dt) + sum(test.cm.dt))

# Random Forest ####
library(caret)
control <- trainControl(method = "repeatedcv", number = 10, repeats = 3, 
                        search="random")
tunegrid <- expand.grid(.mtry = sqrt(ncol(train.x)))
fit.rf <- train(train.x, train.y, method = "rf", metric = "Accuracy",
                tuneGrid = tunegrid, trControl = control)

pred.train.rf <- predict(fit.rf, train.x)
pred.test.rf <- predict(fit.rf, test.x)
train.cm.rf <- table(real = train.y, pred = pred.train.rf)
test.cm.rf <- table(real = test.y, pred = pred.test.rf)
train.acc.rf <- sum(diag(train.cm.rf))/sum(train.cm.rf)
test.acc.rf <- sum(diag(test.cm.rf))/sum(test.cm.rf)
all.acc.rf <- (sum(diag(train.cm.rf)) + sum(diag(test.cm.rf)))/(sum(train.cm.rf) + sum(test.cm.rf))

# SVM ####
library(e1071)
tune.svm <- tune(svm, 
                 train.x = train.x,
                 train.y = train.y,
                 kernel = "radial",
                 type = 'C-classification',
                 range=list(cost=10^(-2:3), gamma=c(.1, .5, 1, 2, 3)))
fit.svm <- tune.svm$best.model

pred.train.svm <- predict(fit.svm, train.x)
pred.test.svm <- predict(fit.svm, test.x)
train.cm.svm <- table(real = train.y, pred = pred.train.svm)
test.cm.svm <- table(real = test.y, pred = pred.test.svm)
train.acc.svm <- sum(diag(train.cm.svm))/sum(train.cm.svm)
test.acc.svm <- sum(diag(test.cm.svm))/sum(test.cm.svm)
all.acc.svm <- (sum(diag(train.cm.svm)) + sum(diag(test.cm.svm)))/(sum(train.cm.svm) + sum(test.cm.svm))

# Bayes ####
library(caret)
tune.bayes <- train(train.x, train.y, 'nb', 
                    trControl = trainControl(method = 'cv', number = 10))
fit.bayes <- tune.bayes$finalModel

pred.train.bayes <- predict(fit.bayes, train.x)$class
pred.test.bayes <- predict(fit.bayes, test.x)$class
train.cm.bayes <- table(real = train.y, pred = pred.train.bayes)
test.cm.bayes <- table(real = test.y, pred = pred.test.bayes)
train.acc.bayes <- sum(diag(train.cm.bayes))/sum(train.cm.bayes)
test.acc.bayes <- sum(diag(test.cm.bayes))/sum(test.cm.bayes)
all.acc.bayes <- (sum(diag(train.cm.bayes)) + sum(diag(test.cm.bayes)))/(sum(train.cm.bayes) + sum(test.cm.bayes))


# Performance comparison ####
my.model <- c(rep("MLR", 3), rep("DT", 3), rep("RF", 3),
              rep("Bayes", 3), rep("SVM", 3))
condition <- rep(c("Train" , "Test" , "All") , 5)
acc.value <- c(train.acc.mlr, test.acc.mlr, all.acc.mlr,
               train.acc.dt, test.acc.dt, all.acc.dt,
               train.acc.rf, test.acc.rf, all.acc.rf,
               train.acc.bayes, test.acc.bayes, all.acc.bayes,
               train.acc.svm, test.acc.svm, all.acc.svm)
bar.data <- data.frame(my.model, condition, acc.value)
bar.data$my.model <- factor(bar.data$my.model, 
                            levels = c('MLR', 'DT', 'RF', 
                                       'Bayes', 'SVM'))
bar.data$condition <- factor(bar.data$condition, 
                             levels = c('Train', 'Test', 'All'))
ggplot(bar.data, aes(fill = condition, y = acc.value, x = my.model)) + 
  geom_bar(position = "dodge", stat = "identity") + 
  theme_bw() + xlab('Models') + ylab('Accuracy') +
  coord_cartesian(ylim = c(min(bar.data$acc.value),
                           max(bar.data$acc.value))) +
  ggtitle('Model performance')
