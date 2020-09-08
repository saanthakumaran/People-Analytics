#install.packages("RMySQL")
library(RMySQL)
#

mydb <- dbConnect(MySQL(), user = 'root', password = 'oracle',
                  dbname = 'project', host = 'localhost')

#
dbListTables(mydb)
#
dbListFields(mydb, 'department_name')
#


#The patients of Psychologist jon with their department, performance, work pressure , treatment status, and leave availed, and have a session with the appropriate HR.
rs2<-dbSendQuery(mydb, "SELECT L.Name AS LABOUR,S.SHOP_FLOOR_DEPARTMENT_NAME AS SHOP_FLOOR_DEPARTMENT,PM.GOALS_ATTAINED_PERCENTAGE AS GOALS_ATTAINED,C.TREATMENT AS TREATMENT_STATUS,C.WORK_PRESSURE AS WORK_PRESSURE,P.RESPECT AS RESPECT,P.AVAILING_LEAVE AS LEAVE_AVAILED, E2.NAME AS HR
FROM LABOUR L, PRODUCTIVITY_MEASURE PM, CONSULTATIONS C, PERFORMANCE P, SHOP_FLOOR_DEPARTMENT S, EMPLOYEE E1, EMPLOYEE E2
                 WHERE L.FLOOR_DEPARTMENT_ID=S.SHOP_FLOOR_DEPARTMENT_ID AND L.LABOUR_ID=C.PATIENT AND L.LABOUR_ID=PM.LABOUR_ID AND L.LABOUR_ID=P.LABOUR AND C.PSYCHOLOGIST_EMPLOYEE_ID = E1.EMPLOYEE_ID AND P.HR_EMPLOYEE=E2.EMPLOYEE_ID AND  E1.NAME='Jon'")

dbFetch(rs2)

#work pressure vs average sleep hours
t<-dbGetQuery(mydb, 'SELECT Work_pressure, sleep_hours, current_medication FROM consultations')

library(ggplot2)
library(dplyr)
str(t)
t$Work_pressure<-as.factor(t$Work_pressure)
t_avg<- group_by(t,Work_pressure) %>% summarize(average_sleep_hours=mean(sleep_hours))
ggplot(data=t_avg, aes(x=Work_pressure, y=average_sleep_hours))+geom_bar(stat="identity")+ggtitle("Relation between Sleep hours(avg) Vs Work Pressure rating")+xlab("Work pressure level")+ylab("Average sleep hours")

#Improvement 
feedback <- dbSendQuery(mydb, "SELECT Improvement_Status from Feedback")
feedbackdf=fetch(feedback,n=-1)
feedbackdf
nrow (filter(feedbackdf, Improvement_Status == "Yes"))
nrow (filter(feedbackdf, Improvement_Status == "No"))
nrow (filter(feedbackdf, Improvement_Status == "NA"))
x <- c(17, 12, 6)
piepercent<- round(100*x/sum(x), 1)
pie(x, labels = piepercent, main = "Feedback", col = rainbow(length(x)))
legend("topright", c("Yes, there is Improvement","No, there is no improvement","Still undergoing treatment"), cex = 0.8,
       fill = rainbow(length(x)))

#
dbClearResult(t)
#
dbDisconnect(mydb)
#