@echo off
if exist materials goto en
:de
rename _gamemodes gamemodes
rename _materials materials
rename _models models
rename _resource resource
rename _sound sound
exit
:en
rename gamemodes _gamemodes
rename materials _materials
rename models _models
rename resource _resource
rename sound _sound
exit