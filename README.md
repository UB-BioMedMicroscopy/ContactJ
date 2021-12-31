# ContactJ

## General Information

**Name of Macro:** ContactJ.ijm\
**Date:** 30th December 2021\
**Objective:** Analyse contacts between fluorescently labelled lipid droplets and mitochondria from cultured cells in confocal microscopy images.\
**Input:** .tif format of Confocal microscopy images (nbits, 1 section) of labelled cells, 3 fluorescent channels (lipid droplet labelling, mitochondria labelling and DNA DAPI labelling).\
Output: The following parameters are quantified from each cell (in um and um2) and stored in a results table, registering the file name and number of cell detected: 
- The total length of the contact sites, the mean length of each contact and the number of contacts detected per cell (a contact is defined as a continuous contact line) between mitochondria and lipid droplets.
 - Cell Area, number of LDs and Mitochondria, LDs and Mitochondria Total Area, Mean LD Area per cell, Standard deviation of the LD mean Area, Mean LD Perimeter, Total Mitochondria and LD Perimeter, Mitochondria Intensity Parameters.

**ImageJ Version:** 1.7

**Requirements:** 
- Advanced Weka Segmentation PMID 28369169, doi:10.1093/bioinformatics/btx180
- Colocalization Plugin (Pierre Bourdoncle, Institut Jacques Monod, Service Imagerie, Paris) https://imagej.nih.gov/ij/plugins/colocalization.html

Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

## Contact information

Gemma Martin (gemmamartin@ub.edu), Maria Calvo (mariacalvo@ub.edu) 
Advanced Optical Microscopy Unit 
Scientific and Technological Centers (CCiTUB). Clinic Medicine Campus 
UNIVERSITY OF BARCELONA 
C/ Casanova 143 
Barcelona 08036 
Tel: 34 934037159 

## How to use ContactJ

ContactJ is macro script for the open-source image analysis software ImageJ. This macro automatically and rapidly quantifies confocal images that are saved in a folder and returns the table of the resulting measurements, images and Regions of Interests (ROIs) in a “Results” folder.
1.	Prepare a set of images and organize them into a folder. In this images folder, create a subfolder named “Model” with the data and model files obtained specifically for the segmentation of the organelle1 channel using the machine learning WEKA plugin. 
2.	Run the macro with ImageJ
3.	The macro will ask to the user for the folder were the images are stored
4.	ContactJ GUI appears and allows choosing name of organelles, thresholds, compensation, colocalization ratio and the possibility to choose the cells to analyse. 
5.	ContactJ opens the images one by one analysing them, cell by cell, and saving ROIs and all the measurements data obtained (areas, intensity

**ContactJ DOI**

 https://doi.org/10.5281/zenodo.5810874 


