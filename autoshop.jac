# Simple Car Garage Customer Management System
import from byllm { Model }

glob llm = Model(model_name="gemini/gemini-2.0-flash");

# Base node for all entities in the system
node GarageEntity{}

# Node to store Customer Information
node Customer(GarageEntity){
    has name: str;
    has phone: str;
    has email: str;
    
    can manage with GarageManager entry {
        visitor.data["customer_name"] = self.name;
        visitor.data["customer_phone"] = self.phone;
        visitor.data["customer_email"] = self.email;
    }
}

# Node to store Vehicle Information
node Vehicle(GarageEntity){
    has make: str;
    has model: str;
    has year: int;
    has license_plate: str;
    
    can manage with GarageManager entry {
        visitor.data["vehicle_make"] = self.make;
        visitor.data["vehicle_model"] = self.model;
        visitor.data["vehicle_year"] = self.year;
        visitor.data["license_plate"] = self.license_plate;
    }
}

# Node to store Service Job Details
node ServiceJob(GarageEntity){
    has service_type: str; # e.g., 'Oil Change', 'Brake Repair', 'Diagnostics'
    has mechanic_notes: str;
    has labor_cost: float;
    has parts_cost: float;
    
    can manage with GarageManager entry {
        visitor.data["service_type"] = self.service_type;
        visitor.data["mechanic_notes"] = self.mechanic_notes;
        visitor.data["labor_cost"] = self.labor_cost;
        visitor.data["parts_cost"] = self.parts_cost;
        visitor.data["total_cost"] = self.labor_cost + self.parts_cost;
    }
}

# Node to trigger the LLM analysis
node ReportGenerator{
    can manage with GarageManager entry {
        # Use the LLM to generate a comprehensive report based on all collected data
        visitor.data["service_report"] = visitor.generate_report(visitor.data);
    }
}

# Walker to manage the data flow and analysis
walker GarageManager{
    has data: dict = {};
    
    can start with `root entry {
        # Traverse from the root to collect data from all connected entities
        visit [-->(`?GarageEntity)];
        visit [-->(`?ReportGenerator)];
    }

    """
    Generate a professional Service Summary and Next Steps Recommendation for the customer.
    
    Data to include:
    - Customer: {customer_name}, {customer_phone}
    - Vehicle: {vehicle_year} {vehicle_make} {vehicle_model} ({license_plate})
    - Service Performed: {service_type}
    - Mechanic Notes: {mechanic_notes}
    - Total Cost: Kshs{total_cost} (Labor: Kshs{labor_cost}, Parts: Kshs{parts_cost})
    
    The summary should be structured as:
    1. **Summary of Work Done**: A brief, easy-to-understand description of the service.
    2. **Key Findings**: Important issues noted by the mechanic.
    3. **Next Steps & Recommendations**: Suggestions for future service, preventative maintenance, or urgent repairs.
    """
    def generate_report(data: dict) -> str by llm();
}

# Program execution block
with entry {
    print("=" * 40);
    print("🚗 CAR GARAGE MANAGEMENT SYSTEM 🛠️");
    print("=" * 40);
    # Inform the user about the required cost input format
    print("\n*** IMPORTANT: Please enter all cost amounts as numbers ONLY (e.g., 5000) ***");
    
    while True {
        print("\n" + "=" * 40);
        choice = input("Start a New Service Job? (yes/exit): ").strip().lower();

        if choice == "exit" {
            print("\n👋 System shutting down. Goodbye!");
            break;
        };
        
        if choice != "yes" {
            continue;
        };
        
        print("\n STARTING NEW JOB");
        print("-" * 20);

        # 1. Customer Details
        print("\n CUSTOMER DETAILS");
        print("-" * 20);
        c_name = input("Customer Name: ");
        c_phone = input("Phone Number: ");
        c_email = input("Email: ");

        # 2. Vehicle Details
        print("\n VEHICLE DETAILS");
        print("-" * 20);
        v_make = input("Make: ");
        v_model = input("Model: ");
        v_year_str = input("Year: "); 
        v_plate = input("License Plate: ");
        
        # 3. Service Job Details
        print("\n SERVICE JOB DETAILS");
        print("-" * 20);
        j_type = input("Service Type (e.g., 'Oil Change'): ");
        j_notes = input("Mechanic Notes: ");
        j_labor_str = input("Labor Cost (Kshs): "); 
        j_parts_str = input("Parts Cost (Kshs): "); 

        # --- Safety Data Conversions (Bypassing compiler issue with try/catch) ---
        v_year = 0;
        if len(v_year_str) > 0 {
            v_year = int(v_year_str); 
        } else {
            print("Warning: Year input was empty. Using default 0.");
        }

        j_labor = 0.0;
        if len(j_labor_str) > 0 {
            j_labor = float(j_labor_str);
        } else {
            print("Warning: Labor Cost input was empty. Using default 0.0.");
        }
        
        j_parts = 0.0;
        if len(j_parts_str) > 0 {
            j_parts = float(j_parts_str);
        } else {
            print("Warning: Parts Cost input was empty. Using default 0.0.");
        }
        # --- End Conversions ---

        # Create and link the tracking nodes to the root
        print("\n🔗 Linking job data to the graph...");
        root ++> Customer(name=c_name, phone=c_phone, email=c_email);
        root ++> Vehicle(make=v_make, model=v_model, year=v_year, license_plate=v_plate);
        root ++> ServiceJob(
            service_type=j_type,
            mechanic_notes=j_notes,
            labor_cost=j_labor,
            parts_cost=j_parts
        );
        root ++> ReportGenerator();

        # Run the report generation walker
        print("\n⚙️ Generating service report using LLM...");
        agent = GarageManager() spawn root;
        
        # Display the final LLM-generated report
        print("\n" + "=" * 60);
        print("                   🛠️ FINAL SERVICE REPORT 🛠️");
        print("=" * 60);
        print(agent.data['service_report']);
        print("=" * 60);
        
        # Check if user wants to process another job
        another = input("\nJob Complete. Process another service job? (yes/no): ").strip().lower();
        if another not in ["yes", "y"] {
            print("\n👋 System shutting down. Goodbye!");
            break;
        };
    }
}
