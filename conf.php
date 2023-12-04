<?php
$servernimi = "localhost";
$kasutajanimi = "";
$parool = "";
$andmebaas = " ";
$yhendus = new mysqli($servernimi, $kasutajanimi, $parool, $andmebaas);
$yhendus->set_charset('UTF8');

if (!$yhendus) {
    die('Ei saa ühendust andmebaasiga');
}