<?php
$serverinimi="localhost";
$kasutajanimi="rainonkaska";
$parool="123456";
$andmebaas="rainonkaskaBarber";
$yhendus=new mysqli($serverinimi, $kasutajanimi, $parool, $andmebaas);
$yhendus->set_charset('UTF8');

if (!$yhendus) {
    die('Ei saa ühendust andmebaasiga');
}