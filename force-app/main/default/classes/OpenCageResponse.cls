public class OpenCageResponse{
	public cls_results[] results;
	public cls_status status;
	
    public class cls_results {
		public cls_components components;
		public Integer confidence;	
		public String formatted;	
		public cls_geometry geometry;
	}
	
	public class cls_components {
		public String city;	
		public String continent;	
		public String country;	
		public String country_code;	
		public String postcode;	
		public String road;	
		public String state;
		public String suburb;
	}
	public class cls_geometry {
		public Double lat;	//-23.5370962
		public Double lng;	//-46.8359735
	}
	public class cls_status {
		public Integer code;	
		public String message;	
	}
	
    public static OpenCageResponse parse(String json){
		return (OpenCageResponse) System.JSON.deserialize(json, OpenCageResponse.class);
	}
}