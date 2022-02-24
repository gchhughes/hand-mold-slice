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
addpath 'C:\Users\griff\github\hand-mold-slice'; % Path where functions are stored

%% Import ROI Data
fprintf('Importing...\n');
s = ImportROIs(filename,path); % Change sheet name to "InProgress" and move data there first
fprintf('Done\n');

%% Alignment
fprintf('Aligning...\n');
s = RigidAlign(s);
s = NonRigidAlign(s); % Requires Mapping, Statistics & Machine Learning Toolboxes
fprintf('Done\n');

%% Statistics
fprintf('Computing Statistics...\n');
s = Statistics(s,path);
fprintf('Done\n');

%% Store Data
fprintf('Storing Data...\n');
storeData(s,path);
fprintf('Done\n');