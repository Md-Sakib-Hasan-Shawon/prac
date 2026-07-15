// Example 1: Basic Polymorphism
// Code
// class animal;

//     virtual function void speak();
//         $display("Animal sound");
//     endfunction

// endclass


// class dog extends animal;

//     function void speak();
//         $display("Dog barks");
//     endfunction

// endclass


// module tb;

//     animal a;

//     initial begin

//         a = new dog();

//         a.speak();

//     end

// endmodule


// // Output
// // Dog barks



// Example 2: Multiple Child Classes
// Code
// class animal;

//     virtual function void speak();
//         $display("Animal sound");
//     endfunction

// endclass


// class dog extends animal;

//     function void speak();
//         $display("Dog barks");
//     endfunction

// endclass


// class cat extends animal;

//     function void speak();
//         $display("Cat meows");
//     endfunction

// endclass


// module tb;

//     animal a;

//     initial begin

//         a = new dog();
//         a.speak();

//         a = new cat();
//         a.speak();

//     end

// endmodule

// // Output
// // Dog barks
// // Cat meows


// Example 3: Array of Parent Handles
// Code
// class animal;

//     virtual function void speak();
//         $display("Animal");
//     endfunction

// endclass


// class dog extends animal;

//     function void speak();
//         $display("Dog");
//     endfunction

// endclass


// class cat extends animal;

//     function void speak();
//         $display("Cat");
//     endfunction

// endclass


// module tb;

//     animal animals[3];

//     initial begin

//         animals[0] = new dog();
//         animals[1] = new cat();
//         animals[2] = new dog();

//         foreach(animals[i])
//             animals[i].speak();

//     end

// endmodule


// // Output
// // Dog
// // Cat
// // Dog



// Example 4: Polymorphism with Additional Child Methods
// Code
// class vehicle;

//     virtual function void start();
//         $display("Vehicle started");
//     endfunction

// endclass


// class car extends vehicle;

//     function void start();
//         $display("Car started");
//     endfunction

//     function void open_door();
//         $display("Door opened");
//     endfunction

// endclass


// module tb;

//     vehicle v;

//     initial begin

//         v = new car();

//         v.start();

//     end

// endmodule


// // Output
// // Car started



// Example 5: Transaction Example (Verification Style)
// Code
// class transaction;

//     virtual function void display();
//         $display("Generic Transaction");
//     endfunction

// endclass


// class ethernet_txn extends transaction;

//     function void display();
//         $display("Ethernet Transaction");
//     endfunction

// endclass


// class spi_txn extends transaction;

//     function void display();
//         $display("SPI Transaction");
//     endfunction

// endclass


// module tb;

//     transaction tx;

//     initial begin

//         tx = new ethernet_txn();
//         tx.display();

//         tx = new spi_txn();
//         tx.display();

//     end

// endmodule
// // Output
// // Ethernet Transaction
// // SPI Transaction