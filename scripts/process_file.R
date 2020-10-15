# data_dir = 'data/'
# setwd(data_dir)

# this version has caseids which we need to map to unique combinations
# of responses
data = read.csv('/tmp/data/RECOVR_caseids_final_melted_for_R.csv', stringsAsFactors = TRUE)

# discard blank
data2 = data[data$value != '',]

# get lookup tables for business sector
# CDI sector
CDI_sector_labels = read.csv('RECOVR_main_job_sector_labels_final.csv')
CDI_sector_labels = CDI_sector_labels[CDI_sector_labels$country == 'CDI', c(1,2,5)]
names(CDI_sector_labels)[names(CDI_sector_labels) == "main_job_sector"] <- "value"

# RWA 
RWA_biz_open_labels = read.csv('RECOVR_biz_still_open_labels_final.csv')
RWA_biz_open_labels = RWA_biz_open_labels[RWA_biz_open_labels$country == 'RWA', c(1,2,5)]
names(RWA_biz_open_labels)[names(RWA_biz_open_labels) == "biz_still_open"] <- "value"

# update these rows
# with data.table
library(data.table)

setDT(data2)[setDT(RWA_biz_open_labels), on = c('country', 'value'), value := i.consolidated_label]
setDT(data2)[setDT(CDI_sector_labels), on = c('country', 'value'), value := i.consolidated_label]

# discard blank
data3 = data2[data2$value != '',]
data3 = droplevels(data3)
levels(data3$value)

# replace other lookup values
labels = read.csv('labels_lookup_final.csv', stringsAsFactors = TRUE)
labels = labels[,c(1,3)]
setDT(data3)[setDT(labels), on = c('value'), value := i.short_value_final]

data3 = data3[data3$value != '',]
data3 = droplevels(data3)
levels(data3$value)

require(reshape2)

wide = dcast(data3[,-c(2)], caseid ~ variable)

# only keep if said yes to biz in feb
wide2 = wide[wide$run_biz_feb == 'Yes' | wide$work_fam_biz_feb == 'Yes', ]

# now count answers by country and sector
# we don't need caseid anymore since each row is unique
wide2$country = do.call('rbind', strsplit(as.character(wide2$caseid), '_'))[,2]
wide_biz = wide2[,c(2,3,6,7)]

# melt by country and sector and question
country_sect_question_counts  = melt(wide_biz, id.vars=c('country', 'main_job_sector'), na.rm=TRUE)

country_sect_counts = dcast(country_sect_question_counts, country + main_job_sector ~ variable + value)

require(dplyr)
# lapply(data3, count)
country_sect_counts2 = country_sect_question_counts %>% count(country, main_job_sector, variable, value)
write.csv(country_sect_counts2, '/tmp/data/country_sect_counts2.csv', row.names=FALSE)