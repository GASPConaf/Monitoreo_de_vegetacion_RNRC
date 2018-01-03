# Monitoreo_de_vegetacion_RNRC
Código R para el análisis multitemporal y el monitoreo de vegetación del ecosistema Estepa en la Reserva Nacional Río de Los Cipreses

Bajo el contexto de actualización del plan de manejo de la Reserva Nacional Río de Los Cipreses (RNRC), se desarrolló una herramienta de monitoreo que permitirá evidenciar los cambios en superficie de la vegetación asociada al objeto de conservación de filtro grueso “Estepa de altura” mediante imágenes satelitales. Este ecosistema agrupa pisos vegetacionales de altitud (2.000-3.500 m s.n.m.) como; herbazal andino, matorral bajo, y comunidades intrazonales, como vegas y matorrales de quebrada (Lüebert y Pliscoff, 2006). Este tipo de vegetación, en muchos casos no es evidente en una imagen satelital, debido a su alta variabilidad estacional, su baja cobertura o por sus tonalidades pardas a blancas que se confunden con el suelo.

La herramienta de monitoreo desarrollada bajo el entorno de programación R (R Core Team, 2017), permite identificar la vegetación de estepa mediante el Índice de Vegetación de Diferencia Normalizada (NDVI). El NDVI es un índice de vegetación basado en la intensidad de la radiación de ciertas bandas del espectro electromagnético que la vegetación refleja. La combinación de estos dominios espectrales permite diferenciar coberturas de vegetación (Bannari et al. 1995).

Con el fin de conocer la superficie de la vegetación de estepa y su variabilidad anual se aplicó este índice a un set de imágenes satelitales en una ventana temporal de cuatro años (2014-2017), se utilizaron imágenes del periodo estival (enero-marzo) con el fin de disminuir las diferencias fenológicas de la vegetación. Para este análisis se utilizó el producto LANDSAT 8 OLI/TIRS C1 Higher-Level, el cual incorpora las correcciones necesarias para disminuir la variabilidad inter-imagen producto de efectos atmosféricos.


![alt text](https://github.com/GapConaf/Monitoreo_de_vegetacion_RNRC/blob/master/RNRC1.png)
