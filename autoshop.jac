# Simple Car Garage Customer Management System
import from byllm { Model }

glob llm = Model(model_name="gemini/gemini-2.0-flash");

# Base node for all entities in the system
node GarageEntity{}

# Node to store Customer Information (Semicolons added)
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

# Node to store Vehicle Information (Semicolons added)
node Vehicle(GarageEntity){
    has make: str;
    has model: str;
    has year: int;
    has engine: int;
    has license_plate: str; 
    
    can manage with GarageManager entry {
        visitor.data["vehicle_make"] = self.make;
        visitor.data["vehicle_model"] = self.model;
        visitor.data["vehicle_year"] = self.year;
        visitor.data["engine_size"] = self.engine; 
        visitor.data["license_plate"] = self.license_plate;
    }
}

# Node to store Service Job Details (Semicolons added)
node ServiceJob(GarageEntity){
    has service_type: str; 
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
    - Engine Size: {engine_size} 
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
    print(" CAR GARAGE MANAGEMENT SYSTEM");
    print("=" * 40);

    # Inform the user about the required cost input format
    print("\n*** IMPORTANT: Please enter all cost amounts as numbers ONLY (e.g., 5000, not 5,000) ***");
    
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
    v_year = input("Year: ");
    v_engine = input("Engine Size (e.g., 1200 for 1.2L): ");
    v_plate = input("License Plate: ");
    
    # 3. Service Job Details
    print("\n SERVICE JOB DETAILS");
    print("-" * 20);
    j_type = input("Service Type (e.g., 'Oil Change'): ");
    j_notes = input("Mechanic Notes: ");
    j_labor = input("Labor Cost (Kshs): ");
    j_parts = input("Parts Cost (Kshs): ");

    # Create and link the tracking nodes to the root
    root ++> Customer(name=c_name, phone=c_phone, email=c_email);
    root ++> Vehicle(make=v_make, model=v_model, year=int(v_year), engine=int(v_engine), license_plate=v_plate); 
    root ++> ServiceJob(
        service_type=j_type,
        mechanic_notes=j_notes,
        labor_cost=float(j_labor),
        parts_cost=float(j_parts)
    );
    root ++> ReportGenerator();

    # Run the report generation walker
    print("\n⚙️ Generating service report...");
    agent = GarageManager() spawn root;
    
    # Display the final LLM-generated report
    print("\n" + "=" * 40);
    print("🛠️ FINAL SERVICE REPORT");
    print("=" * 40);
    print(agent.data['service_report']);
    print("\n" + "=" * 40);
    print(" System Complete. Data stored in graph nodes.");
}