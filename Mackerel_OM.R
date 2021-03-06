#----------------------------------------------------------
#OPERATING MODEL
#NEA Mackerel

#Nekane Alzorriz
#December 2013

# Load the FLCore library
library(FLCore)
library(r4ss)
library(plyr)
library(reshape2)
library(FLa4a)
library(devtools)
library(ggplotFL)

# Load the data
catnage<- read.table ("~/Documents/BoB/MSE/OM/data/Mackerel/Catch number.csv", header=T, dec=".", sep=";")
catwage<- read.table ("~/Documents/BoB/MSE/OM/data/Mackerel/Catch weight.csv", header=T, dec=".", sep=";")
matu<- read.table ("~/Documents/BoB/MSE/OM/data/Mackerel/Mat Ogive.csv", header=T, dec=".", sep=";")
ind<- read.table ("~/Documents/BoB/MSE/OM/data/Mackerel/Index abundance.csv", header=T, dec=".", sep=";")
indvar<- read.table ("~/Documents/BoB/MSE/OM/data/Mackerel/Index variance.csv", header=T, dec=".", sep=";")
stkwage<- read.table ("~/Documents/BoB/MSE/OM/data/Mackerel/Stock weight.csv", header=T, dec=".", sep=";")
disc<-read.table ("~/Documents/BoB/MSE/OM/data/Mackerel/Total Landings.csv", header=T, dec=".", sep=";")

fishmort<- read.table ("~/Documents/BoB/MSE/OM/data/Mackerel/F.csv", header=T, dec=".", sep=";")
biomass<- read.table ("~/Documents/BoB/MSE/OM/data/Mackerel/Biomass.csv", header=T, dec=".", sep=";")
stknage<-read.table ("~/Documents/BoB/MSE/OM/data/Mackerel/Stock number.csv", header=T, dec=".", sep=";")

# Create the FLQuant object
mac.stk <- FLQuant( dimnames = list(age = 0:12, year = 1972:2012, unit = 'unique', season = 'all', area = 'unique'),
                quant = "age")

#We can now transform the FLQuant object into an FLStock object.
mac.stk <- FLStock(mac.stk)

#To see the elements of the object newly created you just have to type: # Name: mac.stk <- "NEA mac.stkkerel"
summary(mac.stk)

#Filling of slots with data
# Total catch
# Catch numbers at age
Year <- as.numeric (sub("X", "", names(catnage[-c(1)])))
flq <- FLQuant( dimnames = list(age = 0:12, year = 1972:2012, unit = 'unique', season = 'all', area = 'unique'),
                quant = "age",  units = '10^3')
flq[as.character(catnage$Age),as.character(Year)] <- as.matrix(catnage[,-c(1)])
catch.n (mac.stk)<-flq

# Catch mean weight at age
Year <- as.numeric (sub("X", "", names(catwage[-c(1)])))
flq<- FLQuant( dimnames = list(age = 0:12, year = 1972:2012, unit = 'unique', season = 'all', area = 'unique'),
               quant = "age", units = 'kg')
flq[as.character(catwage$Age),as.character(Year)] <- as.matrix(catwage[,-c(1)])
catch.wt(mac.stk)<-flq

# Total catches
#landings.n<- window(landings.n, start=1982, end=2012)
#catch (mac.stk)<- apply((catch.n(mac.stk)*catch.wt(mac.stk)), 2, sum,na.rm=TRUE)


# Total catches as found in the report
Year <- as.numeric (sub("X", "", names(disc[-c(1:4)])))
flq <-FLQuant(dimnames = list(age = 'all', year = 1972:2012, unit = 'unique', season = 'all', area = 'unique'),
              quant = "age", units = 't')
flq[,as.character(Year)] <- as.matrix(disc[3,-c(1:4)])
catch(mac.stk)<- flq

#Combined FLQuant with the reporting total catches and the total caches from the SA data computation, 
#where unit 1 is for the one computed
flq <-FLQuant(dimnames = list(age = 'all', year = 1972:2012, unit = c(1,2), season = 'all', area = 'unique'),
              quant = "age", units = 't')
qq<-as.data.frame(catch(mac.stk))
flq[, as.character(qq$year),1]<-as.matrix(qq[,7])
#where unit 2 is for the one reported
aa<-as.data.frame(catch_report)
flq[, as.character(aa$year),2]<-as.matrix(aa[,7])
catch_tot <- flq

## Landings: I have found some disimilarities between landings data. Marina explained me, that converting the landing and discards length to age, 
#they are not considering the age 0, so some of this data has dissapeared.
# Landings number at age
#landings.n (mac.stk)<- NA
# Discards weight at age
#landings.wt (mac.stk)<- NA
# Discards numbers at age
#discards.n (mac.stk)<- NA
# Discards weight at age
#discards.wt (mac.stk)<- NA

# Total landings
Year <- as.numeric (sub("X", "", names(disc[-c(1:4)])))
flq <-FLQuant(dimnames = list(age = 'all', year = 1972:2012, unit = 'unique', season = 'all', area = 'unique'),
              quant = "age", units = 't')
flq[,as.character(Year)] <- as.matrix(disc[2,-c(1:4)])
landings (mac.stk)<- flq

# Total discards
Year <- as.numeric (sub("X", "", names(disc[-c(1:4)])))
flq <-FLQuant(dimnames = list(age = 'all', year = 1972:2012, unit = 'unique', season = 'all', area = 'unique'),
              quant = "age", units = 't')
flq[,as.character(Year)] <- as.matrix(disc[1,-c(1:4)])
discards (mac.stk)<-flq

#TAC
# Year <- as.numeric (sub("X", "", names(disc[-c(1)])))
# flq <-FLQuant(dimnames = list(age = 'all', year = 1984:2005, unit = 'unique', season = 'all', area = 'unique'),
#               quant = "age", units = 't')
# flq[,as.character(Year)] <- as.matrix(disc[4,-c(1)])
# TAC<-flq


#----------------------------------------------------------
#----------------------------------------------------------
#Stock

# Total stock
stock(mac.stk)<- FLQuant( dimnames = list(age = 'all', year = 1972:2012, unit = 'unique', season = 'all', area = 'unique'),
                        quant = "age", units = 't')
# Stock number at age (# STOCK ASSESSMENT OUTPUT FROM THE WORKING GROUP)
Age<-c(0:12)
Year <- as.numeric (sub("X", "", names(stknage[-c(1)])))
flq <-FLQuant(dimnames = list(age = 0:12, year = 1972:2012, unit = 'unique', season = 'all', area = 'unique'),
              quant = "age", units = '10^3')
flq[as.character(Age),as.character(Year)] <- as.numeric(as.matrix(stknage[,-c(1)]))
stock.n (mac.stk)<-flq

# Stock weight at age
Year <- as.numeric (sub("X", "", names(stkwage[-c(1)])))
flq<- FLQuant( dimnames = list(age = 0:12, year = 1972:2012, unit = 'unique', season = 'all', area = 'unique'),
               quant = "age", units = 'kg')
flq[as.character(stkwage$Age),as.character(Year)] <- as.matrix(stkwage[,-c(1)])
stock.wt (mac.stk)<-flq


#Natural mortality rate, natural mortality rate before spawning and maturity

#Natural mortality is 0.15
#natmort<- read.table ("~/Documents/BoB/MSE/OM/data/mac.stkkerel/Natural mortality.csv", header=T, dec=".", sep=";")

#Natural mortality before spawning is 0.35
#natspw<- read.table ("~/Documents/BoB/MSE/OM/data/mac.stkkerel/Nat Mort before spw.csv", header=T, dec=".", sep=";")

# Natural mortality rate
m (mac.stk)<- 0.15
units(m(mac.stk))<- 'm'  

# Natural mortality rate before spawning
m.spwn (mac.stk)<- 0.35
units(m.spwn(mac.stk))<- 'NA'

# Maturity
Year <- as.numeric (sub("X", "", names(matu[-c(1)])))
flq<- FLQuant( dimnames = list(age = 0:12, year = 1972:2012, unit = 'unique', season = 'all', area = 'unique'),
               quant = "age")
flq[as.character(matu$age),as.character(Year)] <- as.matrix(matu[,-c(1)])
mat(mac.stk)<-flq


# Harvest rate and harvest rate before spawning 
# We have also assumed that we only have information about the harvest rate before spawning and we set harvest at any other time equal to 0.
# Information about harvest in the FLStock object will be used to calculate selectivity as described in (fbom.pdf) .
# If such information is not available but information on selectivity does exist an FLOgive object can still be created.

#Harvest before spawning is 0.421 along the ages and years
#harvspw<- read.table ("~/Documents/BoB/MSE/OM/data/mac.stkkerel/Harvest before spw.csv", header=T, dec=".", sep=";") 

# Harvest rate (# STOCK ASSESSMENT OUTPUT FROM THE WORKING GROUP)
#Fishing mortality
Age<-c(0:12)
Year <- as.numeric (sub("X", "", names(fishmort[-c(1)])))
flq <-FLQuant(dimnames = list(age = 0:12, year = 1972:2012, unit = 'unique', season = 'all', area = 'unique'),
              quant = "age", units = 'f')
flq[as.character(Age),as.character(Year)] <- as.numeric(as.matrix(fishmort[,-c(1)]))
harvest(mac.stk)<-flq

  # Harvest rate before spawning
harvest.spwn (mac.stk) <- 0.421 
units(harvest.spwn(mac.stk))<- 'NA'


# Fully selected ages
range(mac.stk,'minfbar')<-4 
range(mac.stk,'maxfbar')<-8 

# Control if everything has been filled properly
                                                                                                                       
# We can now check that all slots of the FLStock object have been fille:  summary(MAC)
                                                                                                                        
#  To check that “stock” is properly initialised, we can do it like this: catch(MAC)                                                                                                                         
                                                                                                            
# The last step in the source code saves the FLStock object into an Rdata file
# which you can load when you start an R session using the “load” command.
                                                                                                                        
#save(mac.stk,catch_report, catch_tot,file="~/Documents/BoB/MSE/OM/data/Mackerel/MAC.stock.RData")




#1. Index value
Year <- as.numeric (sub("X", "", names(ind[-c(1,43)])))
flq <-FLQuant(dimnames = list(age = 'all', year = 1972:2012, unit = 'unique', season = 'all', area = 'unique'))
flq[,as.character(Year)] <- as.numeric(as.matrix(ind[1,-c(1,43)]))
mac.idx<-FLIndex(index=flq)
units(index(mac.idx))<-'10^-12 eggs'

range(mac.idx,'startf')<-0.5 #
range(mac.idx,'endf')<-0.5 #

#Index variance
#flq[,as.character(Year)] <- as.numeric(as.matrix(ind[2,-c(1)]))
#index.var<-flq
#idx1<- FLIndex(index=idx,index.var=index.var, name='biomass', desc='survey indices and variance (inverse weights)')


#2. CPUE
Year <- c(1983:2012)
flq <-FLQuant(dimnames = list(age = 'all', year = 1983:2012, unit = 'unique', season = 'all', area = 'unique') )
flq[,as.character(Year)] <- as.numeric(as.matrix(ind[9,2:31]))
idx<-flq
idx2<- FLIndex(index=idx, name='TrawlAviles', desc='CPUE, Kg/100CV')
range(idx2,'startf')<-0 #
range(idx2,'endf')<-1 #

#3. CPUE
Year <- c(1983:2012)
flq <-FLQuant(dimnames = list(age = 'all', year = 1983:2012, unit = 'unique', season = 'all', area = 'unique') )
flq[,as.character(Year)] <- as.numeric(as.matrix(ind[10,2:31]))
idx<-flq
idx3<- FLIndex(index=idx, name='TrawlACoruna', desc='CPUE, Kg/100CV')
range(idx3,'startf')<-0 #
range(idx3,'endf')<-1 #

#4. CPUE
Year <- c(1983:2012)
flq <-FLQuant(dimnames = list(age = 'all', year = 1983:2012, unit = 'unique', season = 'all', area = 'unique') )
flq[,as.character(Year)] <- as.numeric(as.matrix(ind[11,2:31]))
idx<-flq
idx4<- FLIndex(index=idx, name='HookSantander', desc='CPUE, Kg/N Fishing trips')
range(idx4,'startf')<-0 #
range(idx4,'endf')<-1 #

#5. CPUE
Year <- c(1983:2012)
flq <-FLQuant(dimnames = list(age = 'all', year = 1983:2012, unit = 'unique', season = 'all', area = 'unique') )
flq[,as.character(Year)] <- as.numeric(as.matrix(ind[12,2:31]))
idx<-flq
idx5<- FLIndex(index=idx, name='HookSantona', desc='CPUE, Kg/N Fishing trips')
range(idx5,'startf')<-0 #
range(idx5,'endf')<-1 #

mac.idx<-FLIndices(ind1=mac.idx,ind2=idx2,ind3=idx3,ind4=idx4,ind5=idx5)
save(mac.stk,mac.idx,file="~/Documents/BoB/MSE/OM/data/Mackerel/mac.RData")
#----------------------------------------------------------
## STOCK ASSESSMENT OUTPUT FROM THE WORKING GROUP
#----------------------------------------------------------
#Fishing mortality
Age<-c(0:12)
Year <- as.numeric (sub("X", "", names(fishmort[-c(1)])))
flq <-FLQuant(dimnames = list(age = 0:12, year = 1972:2012, unit = 'unique', season = 'all', area = 'unique'))
flq[as.character(Age),as.character(Year)] <- as.numeric(as.matrix(fishmort[,-c(1)]))
MAC.SA_f<-flq

#BIOMASS
Param<-c('RECRUITSage0','TSB','SSB','FBAR4-8','LANDINGS','LANDINGSSOP')
Year <- as.numeric (sub("X", "", names(biomass[-c(1)])))
flq <-FLQuant(dimnames = list(Param, year = 1972:2012, unit = 'unique', season = 'all', area = 'unique'))
flq[as.character(Param),as.character(Year)] <- as.numeric(as.matrix(biomass[1:6,-c(1)]))
MAC.SA_Biomass<-flq

#STOCK.N
Age<-c(0:12)
Year <- as.numeric (sub("X", "", names(stknage[-c(1)])))
flq <-FLQuant(dimnames = list(age = 0:12, year = 1972:2012, unit = 'unique', season = 'all', area = 'unique'))
flq[as.character(Age),as.character(Year)] <- as.numeric(as.matrix(stknage[,-c(1)]))
MAC.SA_stock.n<-flq


save(MAC.SA_f, MAC.SA_Biomass, MAC.SA_stock.n,file="~/Documents/BoB/MSE/OM/data/Mackerel/MAC.SAoutput.RData")
