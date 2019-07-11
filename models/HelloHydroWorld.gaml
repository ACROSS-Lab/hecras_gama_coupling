/***
* Name: HelloHydroWorld
* Author: kevinchapuis
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model HelloHydroWorld

global {
	//definiton of the file to import
	file grid_data <- file("../includes/Hello DEM 200x100.MergedInputs.tif") ;
	
	float regex_val <- -9999.0;
	
	//computation of the environment size from the geotiff file
	geometry shape <- envelope(grid_data);
	
	list<mnt> water_body;	
	
	float max_value;
	float min_value;
	init {
		max_value <- mnt max_of (each.grid_value);
		min_value <- (mnt where (each.grid_value > regex_val)) min_of (each.grid_value);
		int x_max <- (mnt with_max_of (each.grid_x)).grid_x;
		write x_max;
		write "Max value = "+max_value;
		write "Min value = "+min_value;
		ask mnt {
			if(grid_value = regex_val){
				color <- #black;
			} else if(grid_value = max_value){
				color <- #white;
			} else {
				land_use <- "water"; 
				int val <- int(255 * (grid_value - min_value) / (max_value - min_value));
				color <- rgb(val,val,255);
				water_body <+ self;
			}
		}
		
		
		ask 4 among (mnt where (each.grid_value = max_value and each.grid_x < x_max/2)) {
			bool stop <- false;
			rgb neighbor_color <- rnd_color(255);
			create house with:[location::self.location,my_place::self, color::neighbor_color] returns:the_houses;
			self.land_use <- the_houses[0];
			mnt current_mnt <- self;
			loop while:not(stop) {
				
				list nghbs <- current_mnt neighbors_at 2 where (not(each.land_use is house)
					and each.grid_value = max_value and each.grid_x < x_max/2);
				if(empty(nghbs)){stop <- true; break;}
				
				current_mnt <- any(nghbs);
				
				create house with:[location::current_mnt.location,my_place::current_mnt, color::neighbor_color] returns:h;
				current_mnt.land_use <- h[0];
				
				if flip(0.05) {stop <- true;}
			}
		}
		
		ask house {
			create people number:10 with:[location::any_location_in(self),my_house::self];
		}
	}
}

//definition of the grid from the geotiff file: the width and height of the grid are directly read from the asc file. The values of the asc file are stored in the grid_value attribute of the cells.
grid mnt file: grid_data neighbors:4 {
	rgb color;
	agent land_use;
}

species water {
	
}

species house {
	mnt my_place;
	rgb color;
	aspect ThreeDhouse {
		draw cube(my_place.shape.width) color:color;
	}
}

species people skills:[moving]{
	house my_house;
	mnt the_site;
	float speed <- 1#m/#s;
	
	path tptf;
	
	bool working;
	
	init {
		tptf <- path_between(topology(mnt),my_house.my_place,water_body closest_to self);
		the_site <- mnt first_with (geometry(any(tptf.vertices)).location intersects each);
	}
	
	reflex go_build_a_dyke when:the_site!=nil and not(working){
		 do goto target:the_site on:mnt where (each.land_use!="water" and not(each.land_use is house));
		 if location overlaps the_site {
		 	working <- true;
		 	location <- any_location_in(the_site);
		 }
	}
	
	reflex build_dyke when:working {
		 if(the_site.land_use=nil){the_site.land_use <- "dyke";}
		 the_site.grid_value <- the_site.grid_value + 1;
		 the_site.color <- rgb(the_site.grid_value,the_site.grid_value/2,0);
	}
	
	aspect default {
		draw circle(1) color:#black;
	}
}

experiment xp type:gui {
	output {
		display hellowrold {
			grid mnt;
			species house aspect:ThreeDhouse;
			species people;
		}
	}
}