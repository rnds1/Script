@echo off
set nome=%computername%
%nome% >%nome%.txt
@wmic bios get SerialNumber >>%nome%.txt
@wmic cpu get Name, NumberOfCores, ThreadCount, SocketDesignation >>%nome%.txt
@wmic MEMORYCHIP get Capacity, Manufacturer,PartNumber >>%nome%.txt
@wmic DISKDRIVE get Size,Model >>%nome%.txt



pause


