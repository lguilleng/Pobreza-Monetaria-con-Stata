/* Indicadores de Pobreza Monetaria */

use sumaria-2021, clear
describe gashog2d linpe linea

g gpcm=gashog2d/12/mieperho
label var gpcm "gasto per cápita mensual“
sum gpcm, d


/* CALCULO DE LOS INDICADORES P0, P1 y P2 POR CADA HOGAR EN LA MUESTRA
   POBREZA MONETARIA TOTAL ---> Linea de pobreza total (Z) = linea */

/* Si Z-Xi <0, entonces indicador=0 */
gen indicador=0  
replace indicador=1 if gpcm<=linea /* identifica a los pobres */

 /* Calculo de los indicadores FGT por hogar
    alpha=0  (INCIDENCIA DE POBREZA)
    alpha=1  (BRECHA DE POBREZA)
    alpha=2  (SEVERIDAD DE POBREZA) */
	
gen p0=indicador*((linea-gpcm)/linea)^0
gen p1=indicador*((linea-gpcm)/linea)^1
gen p2=indicador*((linea-gpcm)/linea)^2

/* Estimación de los indicadores P0, P1 y P2 expandido al total de la población objetivo de la encuesta */ 


g facpob=factor07*mieperho /* Necesitamos factor de expansión de personas */
svyset conglome [pw=facpob], strata(estrato) /* Estructura compleja de la muestra */
svy: mean p0 p1 p2 /* Estimamos P0, P1 y P2 para el total de personas Perú 2021 */


/* CALCULO DE LOS INDICADORES P0, P1 y P2 POR CADA HOGAR EN LA MUESTRA
   POBREZA MONETARIA EXTREMA ---> Linea de pobreza alimentaria (Z) = linpe */

 /* Si Z-Xi <0, entonces indicador=0 */
gen indicador_e=0 
replace indicador_e=1 if gpcm<=linpe /* identifica a los pobres extremos */

 /* Calculo de los indicadores FGT por hogar
    alpha=0  (INCIDENCIA DE POBREZA EXTREMA)
    alpha=1  (BRECHA DE POBREZA EXTREMA)
    alpha=2  (SEVERIDAD DE POBREZA EXTREMA) */

gen p0_e=indicador_e*((linpe-gpcm)/linpe)^0
gen p1_e=indicador_e*((linpe-gpcm)/linpe)^1
gen p2_e=indicador_e*((linpe-gpcm)/linpe)^2

/* Estimación de los indicadores P0, P1 y P2 expandido al total de la población objetivo de la encuesta */ 

svy: mean p0_e p1_e p2_e /* EstimamosP0, P1 y P2 para el total de personas Perú 2021 */

/* Crear variable departamento */

g dep=substr(ubigeo,1,2)
destring dep, replace
label define dep ///
1 "Amazonas" /// 
2 "Ancash" ///
3 "Apurímac" ///
4 "Arequipa" ///
5 "Ayacucho" ///
6 "Cajamarca" ///
7 "Prov. Const. del Callao" ///
8 "Cusco" ///
9 "Huancavelica" ///
10 "Huánuco" ///
11 "Ica" ///
12 "Junín" ///
13 "La Libertad" ///
14 "Lambayeque" ///
15 "Lima" ///
16 "Loreto" ///
17 "Madre de Dios" ///
18 "Moquegua" ///
19 "Pasco" ///
20 "Piura" ///
21 "Puno" ///
22 "San Martín" ///
23 "Tacna" ///
24 "Tumbes" ///
25 "Ucayali", replace

label value dep dep
label dep "departamento"



 * Calculo de la estimación de P0 por departamento */
collect clear
forvalues i = 1/25 {
    quietly: collect _r_b _r_se _r_ci: svy: mean p0 if dep==`i' 
	}

collect style cell result[_r_b _r_se _r_ci], nformat(%8.5f)
collect label levels result _r_b "Incidencia", modify
collect label levels cmdset ///
1 "Amazonas" /// 
2 "Ancash" ///
3 "Apurímac" ///
4 "Arequipa" ///
5 "Ayacucho" ///
6 "Cajamarca" ///
7 "Prov. Const. del Callao" ///
8 "Cusco" ///
9 "Huancavelica" ///
10 "Huánuco" ///
11 "Ica" ///
12 "Junín" ///
13 "La Libertad" ///
14 "Lambayeque" ///
15 "Lima" ///
16 "Loreto" ///
17 "Madre de Dios" ///
18 "Moquegua" ///
19 "Pasco" ///
20 "Piura" ///
21 "Puno" ///
22 "San Martín" ///
23 "Tacna" ///
24 "Tumbes" ///
25 "Ucayali", modify
collect layout (cmdset) (result)


/* DOMINANCIA ESTOCASTICA */

/* Creamos la variable que mide el número de veces que el indicador de bienestar se encuentra en la linea de pobreza
   gpcm / linea, cuando esta relación es igual a 1, estará indicando el valor de la línea de pobreza. */

generate zr=gpcm/linea

/* Creamos las frecuencias relativas acumuladas de la población para Cajamarca y La Libertad */

cumul zr if dep==6 [aw=facpob], generate(pob_6)
cumul zr if dep==13 [aw=facpob], generate(pob_13)
label var pob_6 "Cajamarca"
label var pob_13 "La Libertad"

/* Graficamos */

line pob_6 pob_13 zr if zr<7, sort xline(0.5 1 1.5) xlab(0 0.5 1 1.5 2 4 6 8) ytitle("Prop. acum. población") xtitle("gasto per cápita mensual / linea de pobreza") text(0.5 3 "En el intervalo de una linea relativa de 0.5 y 1.5, \nla relación de mantiene", place(NE))


/* La brecha de pobreza monetaria en el Perú */

svyset conglome [pw=facpob], strata(estrato)
svy: mean p1
estat cv

/* ¿cuál es la incidencia y brecha de pobreza monetaria en la población que reside
   en hogares con no mas de 4 miembros */

   svy, subpop(if mieperho<=4): mean p0 p1

   * otra forma
   g subpop=mieperho<=4
   svy: mean p0 p1, over(subpop)

/* Descomposición de los indicadores de clase Pα (Foster-Greer-Thorbecke) */

   * Total del paós
   povdeco gpcm [aw=facpob], varpl(linea)

   * Descomponiendo la pobreza por Costa, Sierra, Selva y Lima Metropolitana
   g region=dominio<=3
   replace region=2 if dominio>=4 & dominio<=6
   replace region=3 if dominio==7
   replace region=4 if dominio==8
   label define region 1 "Costa" 2 "Sierra" 3 "Selva" 4 "Lima Metropolitana"
   label value region región
   povdeco gpcm [aw=facpob], varpl(linea) by(region)
