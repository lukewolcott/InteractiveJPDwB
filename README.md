# InteractiveJPDwB
interactive Javaplex demo with barcodes

## What is it?

Javaplex is a program for running computations in topological data analysis.  See https://github.com/appliedtopology/javaplex, or the tutorial at https://github.com/appliedtopology/javaplex/wiki/Tutorial.  Javaplex can be set up to run within Processing, an IDE and programming language well-suited for visualization.  The Javaplex download comes with a sample Processing sketch called javaplexDemo.pde.

This repo contains the files needed to run InteractiveJPDwB.pde, a Processing sketch that builds on javaplexDemo.pde.  

InteractiveJPDwB allows the user to create a 2D data set with mouse clicks.  It simultaneously computes and outputs the persistent homology barcode, allowing the user to explore the relationship between data and barcode.

## How do I use InteractiveJPDwB?

For the time being, you need to download both the sketch "InteractiveJPDwB.pde" and the "data" folder into a common directory.  Open InteractiveJPDwB.pde with Processing, and run the sketch.  Instructions appear at the bottom of the screen.

## What is new?

The original javaplexDemo.pde allowed the user to create a 2D data set with mouse clicks.  The left and right arrows would fill in the Vietoris-Rips complex with lines and triangles.  The persistence intervals could be computed, and would print to the sketch window.

The main contribution of InteractiveJPDwB is to generate a barcode from the persistence intervals, and to update the barcode whenever the data set is changed.  It also adds the pre-loaded data sets #1-4.