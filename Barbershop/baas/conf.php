<?php
$serverinimi="localhost";
$kasutajanimi="rainonkaska";
$parool="123456";
$andmebaas="rainonkaskaBarber";
$yhendus=new mysqli($serverinimi, $kasutajanimi, $parool, $andmebaas);
$yhendus->set_charset('UTF8');