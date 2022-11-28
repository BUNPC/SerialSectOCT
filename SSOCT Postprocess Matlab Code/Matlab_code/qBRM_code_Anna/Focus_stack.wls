#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory["C:\\Users\\blank\\OneDrive\\_Documents\\_BU\\_Bigio\\Images\\Aging_Study\\AM355_Largescale_Widefield_exp2ms_mag4X\\ROIs\\ROI_1\\IMG_SEQ"];


names = FileNames[];
a = Import /@ names;
Print["Her12"]
b = ImageFocusCombine[a];
Print["Here2"]
Export["Focus_stacked_new.tiff",b];
Print["Here3"]



