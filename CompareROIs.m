%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   CompareROIs                                                          %
%   CASIT                                                                %
%   Author: Griffith Hughes                                              %
%   Date:   01/18/2022                                                   %
%   Main function for comparing ROI information                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clear Cache
clear all
close all
clc

%% File Selection
[filename,path] = uigetfile('*');
cd(path);
addpath 'C:\Users\griff\Documents\MATLAB\jake-code'

%% Import ROI Data
fprintf('Importing...\n');
s = ImportROIs(filename,path);

%% Alignment
fprintf('Aligning...\n');
s = RigidAlign(s);
s = NonrigidAlignment(s);

%% Statistics + Store Data
fprintf('Computing Statistics...\n');
patients = Statistics(patients);
fprintf('Storing Data...\n');
storeData(patients);
fprintf('Done\n');