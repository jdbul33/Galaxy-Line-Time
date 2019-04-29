/* Data Import and Split */

data galaxy;
	infile "/home/johnbulger0/Time_Series/Project/Data_for_Model.csv" dlm=',' firstobs=2;
	input date_string $ X;
	t = _n_;
	run;
	

data galaxy_w_date;
	set galaxy;
	Date = INTNX('Month', '15Jan2013'D, _N_-1);
	FORMAT Date MONYY7.;
	drop date_string;
run;
	
data modeling;
	set galaxy_w_date(obs=64);
run;

data forecasting;
	set galaxy_w_date(firstobs=65);
run;






/* Classical Decomposition */

PROC TIMESERIES data=modeling OUTDECOMP=Decomp;
     	ID Date INTERVAL=MONTH;
DECOMP _ALL_ / MODE=add;
VAR X;
RUN;

DATA Decomp;
SET Decomp;
T = _N_;
RUN;

PROC REG data=Decomp OUTEST=Coef;
MODEL SA = T;
RUN;
QUIT;

PROC SQL;
SELECT Intercept INTO: Intercept_Value SEPARATED BY ''
FROM Coef;
QUIT;

PROC SQL;
SELECT T INTO: Slope_Value SEPARATED BY ''
FROM Coef;
QUIT;

DATA Decomp;
SET Decomp;
Trend = &Intercept_Value + T*&Slope_Value;
Estimate = Trend + SC;
Error = Original - Estimate;
RUN;

data seasonal_component_for_forecast;
	set decomp(firstobs=5 obs=16);
	keep SC;
run;

/*  */
/* SYMBOL1 INTERPOL=join VALUE=dot COLOR=BLACK LINE=1; */
/* SYMBOL2 INTERPOL=join VALUE=U COLOR=RED LINE=2 FONT=marker; */
/* AXIS1 LABEL=none; */
/* PROC PLOT DATA=Decomp; */
/* PLOT TCC*Date SIC*Date SIC*Date SA*Date Error*Date; */
/* RUN; */
/* QUIT; */
/* PROC PLOT DATA=Decomp; */
/* PLOT Original*Date='x' Estimate*Date='' / OVERLAY BOX; */
/* RUN; */
/* QUIT; */


/* ARIMA Fitting */

/* Looks like 1 diff is the best */
proc arima data=modeling plots=series(all);
	identify var=X(0,12) stationarity=(adf);
run;

/* SARIMA */

/* Need to determine model possiblities */


proc arima data=modeling;
	identify var=x(1,12);
	estimate p=(1)(12) q=(1);
run;

proc arima data=modeling;
	identify var=x(1,12);
	estimate p=(0)(12) q=(1);
run;

proc arima data=modeling;
	identify var=x(1,12);
	estimate p=(1)(12) q=(0);
run;

proc arima data=modeling;
	identify var=x(1,12);
	estimate p=(1,2)(12) q=(1);
run;

proc arima data=modeling;
	identify var=x(1,12);
	estimate p=(1)(12) q=(1,2);
run;

proc arima data=modeling;
	identify var=x(1,12);
	estimate p=(1,2)(12) q=(1,2);
run;

/* Best two models */

proc arima data=modeling;
	identify var=x(1,12) WHITENOISE=IGNOREMISS;
	estimate p=(0)(12) q=(1);
	forecast out=residuals1 lead=0;
run;

proc univariate data=residuals1 normal;
	var residual;
	probplot residual / normal (mu=est sigma=est) square;
run;
quit;

	/* These needs to be done for second best model as well */

proc arima data=modeling;
	identify var=x(1,12) WHITENOISE=IGNOREMISS;
	estimate p=(1)(12) q=(1);
	forecast out=residuals2 lead=0;
run;

proc univariate data=residuals2 normal;
	var residual;
	probplot residual / normal (mu=est sigma=est) square;
run;
quit;







/* Forecasting */

/* Classical Decomp */

data forecasting_ready;
	merge forecasting seasonal_component_for_forecast;
run;

DATA Decomp_forecast;
SET forecasting_ready;
Trend = &Intercept_Value + T*&Slope_Value;
Estimate = Trend + SC;
Errors = X - Estimate;
RUN;

data decomp_results;
	set decomp_forecast;
	sq_er = errors**2;
run;

proc print data=decomp_results;
	sum sq_er;
run;

/* Best Two ARIMA */


proc arima data=modeling;
	identify var=x(1,12) WHITENOISE=IGNOREMISS;
	estimate p=(0)(12) q=(1);
	forecast out=forecast1 lead=12;
run;

data arima_01_10_forecast;
	set forecast1(firstobs=65);
	keep forecast;
run;


data arima_01_10_results;
	merge forecasting arima_01_10_forecast;
	est_error = X - forecast;
	sq_er = est_error**2;
run;

proc print data=arima_01_10_results;
	sum sq_er;
run;

	/* need to do second model too and join on actual X values */

proc arima data=modeling;
	identify var=x(1,12) WHITENOISE=IGNOREMISS;
	estimate p=(1)(12) q=(1);
	forecast out=forecast2 lead=12;
run;


data arima_11_10_forecast;
	set forecast2(firstobs=65);
	keep forecast;
run;


data arima_11_10_results;
	merge forecasting arima_11_10_forecast;
	est_error = X - forecast;
	sq_er = est_error**2;
run;

proc print data=arima_11_10_results;
	sum sq_er;
run;


/* Exponential Smoothing */

/* Month Seasonal */

proc hpf data=modeling lead=12 print=all outfor=hpf_winters_forecast;
	forecast X / model=winters;
	id date interval=month;
run;

data winters_results;
	set hpf_winters_forecast(firstobs=65);
	keep PREDICT;
run;

data monthly_winters_results;
	merge forecasting winters_results;
	est_error = X - PREDICT;
	sq_er = est_error**2;
run;

proc print data=monthly_winters_results;
	sum sq_er;
run;


