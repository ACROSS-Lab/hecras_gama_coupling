/***
* Name: HelloHydroWorld
* Author: kevinchapuis
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model HelloHydroWorld

global {
	//definiton of the file to import
	file grid_data <- file("../includes/Hello Terrain 5m.MergedInputs.tif") ;
	
	float regex_val <- -9999.0;
	
	//computation of the environment size from the geotiff file
	geometry shape <- envelope(grid_data);	
	
	float max_value;
	float min_value;
	init {
		max_value <- mnt max_of (each.grid_value);
		min_value <- (mnt where (each.grid_value > regex_val)) min_of (each.grid_value);
		write "Max value = "+max_value;
		write "Min value = "+min_value;
		ask mnt {
			if(grid_value = regex_val){
				color <- #black;
			} else if(grid_value = max_value){
				color <- #white;
			} else {
				int val <- int(255 * (grid_value - min_value) / (max_value - min_value));
				color <- rgb(val,val,255);
			}
		}
	}
}

//definition of the grid from the geotiff file: the width and height of the grid are directly read from the asc file. The values of the asc file are stored in the grid_value attribute of the cells.
grid mnt file: grid_data;

experiment xp type:gui {
	output {
		display hellowrold {
			grid mnt;
		}
	}
}