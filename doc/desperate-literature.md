### Reseñas poéticas

Estos poemillas han sido generados utilizando reseñas extraídas de Google Maps. Cada reseña es dividida en frases que se envían al servicio Cloud Natural Language API también de Google. Este servicio devuelve las frases con el número de sílabas que las componen, análisis de sentimiento y su magnitud.

El sentimiento es representado por un número entre -1.0 (sentimiento negativo) y 1.0 (sentimiento positivo). La magnitud es un valor entre 0.0 e infinito que representa la intensidad del sentimiento. Como ejemplo, la expresión "¡Es un lugar histórico!" es etiquetada con sentimiento 0.8999 y magnitud 0.8999. Ambos valores son guardados en una base de datos junto a su rima asonante (i|o) y asonante (i|co).

Para componer nuevos poemas solo tenemos que elegir el tipo de rima, número de sílabas en cada verso, el tamaño de cada estrofa, el intervalo de sentimiento y si queremos que ese sentimiento vaya creciendo o decreciendo.

Código disponible en https://github.com/marcelinollano/poetic-reviews/

#### Puerta del Sol

Para las dos siguientes composiciones sobre la Puerta del Sol en Madrid se emplearon 290 reseñas, divididas en 1089 frases. En ambos casos las estrofas son de 4 versos de 8 sílabas y rima asonante. En _El lugar_ el sentimiento es positivo (entre 0.0 y 1.0) ordenado con magnitud creciente. Para _Kilómetro cero_ el sentimiento es negativo (entre -1.0 y 0.0) ordenado con magnitud decreciente.

##### El lugar

```
¡Es un lugar histórico!       (Elena Uwein)
¡Gran interés turístico!      (Selene Serrano)
Un lugar espectacular,        (David Lerma Hincapié)
siempre da gusto pasear.      (Carmen González)
```

##### Kilómetro cero

```
Y el kilómetro cero,          (Jorge Galián)
caminar como borregos.        (Guille Ferrete)
Todo muy abandonado,          (Iris del monte rio)
los bares cercanos caros.     (Gabriel Sanchez)

Mucha gente y conflitos,      (jose manuel lopez rodriguez)
los gintonics mal servidos.   (Pedro Antonio Alonso Garcia)
Mucho actor y disfraces,      (zekeriya sanz)
cuidado por esos lares.       (Gambrinus)
```

#### Primark

Para esta composición sobre la tienda de ropa Primark en la Gran Vía de Madrid se emplearon 463 reseñas, divididas en 1807 frases. Las estrofas son de 3 versos de 6 sílabas y rima asonante. El sentimiento va de -1.0 a 1.0 con magnitud decreciente.

##### Ropa de combate

```
Ropa de combate,              (Fernando Prado Larburu)
Genial super grande!          (cristina ampudia gomez)
Muy recomendable.             (Gaspar Vidal Castañer)

Prendas estupendas.           (Maria Isabel Hormaechea Gorria)
Pero en general               (Mireia Basachs)                 
Nadie lo respeta.             (Marta Hernández-Gil)

Muy economica,                (Pablo Pereira)
No de gran calidad            (udh milstein)
Eso no es primark.            (aida mateos)  
```

Marcelino Llano, Sept 2018.
