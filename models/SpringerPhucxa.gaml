/***
* Name: SpringerPhucxa
* Author: kevinchapuis
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model SpringerPhucxa

global {
	
	file grid_data <- file("../results/HelloDEM200x100.tif") ;
	file building_data <- file("../includes/GIS data Phuc Xa/new_building_phuc_xa.shp");
	file road_data <- shape_file("../results/pedestrian.shp");

	int nb_agent parameter:true init:10;
	
	geometry shape <- envelope(grid_data);
	
	graph pedestrian_network;
	
	// UTILS
	float mnt_height <- first(mnt).shape.height;
	float mnt_width <- first(mnt).shape.width;
	
	init {
		create building from:building_data;
		create road from:road_data;
		pedestrian_network <- as_edge_graph(road);
		
		create people number:nb_agent with:[location::any_location_in(any(building where (each.location overlaps world)))];
		
		float maxgv <- max(mnt collect each.grid_value);
		float mingv <- min(mnt collect each.grid_value);
		
		ask mnt {
			float val <- (grid_value - mingv) / (maxgv - mingv) * 255;
			color <- grayscale(rgb(val, val, val));
		}
	}
	
}

species people skills:[moving] {
	
	float speed;
	mnt my_cell -> mnt grid_at {location.x / mnt_height,location.y /mnt_width};
	 
	
	reflex move_around {
		do wander on:pedestrian_network;
	}
	
	aspect default {
		draw triangle(1.5) rotated_by heading;
		draw my_cell.shape.contour color:#yellow;
	}
	
}

species building {
	
	aspect default {
		draw shape.contour color:#firebrick;
		draw shape color:rgb(#firebrick,0.05);
	}
	
}

species road {
	aspect default {draw shape color:#black;}
}

grid mnt file:grid_data { 
	rgb color;
	init {
		if grid_value = -9999 {grid_value <- 10.0;}
	}
} 

experiment visual {
	output {
		display phuc_xa {
			grid mnt;
			species building;
			species road;
			species people;
		}	
	}
}