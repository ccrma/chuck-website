//-----------------------------------------------------------------------------
// name: score-edit.ck
// desc: This example shows how to edit the measure contents of a part, 
// showing add, delete, insert, and replace functions
//
// author: Alex Han (https://ccrma.stanford.edu/~alexhan/)
//-----------------------------------------------------------------------------

@import "smuck"

// Create a bunch of measures
ezMeasure m1("c");
ezMeasure m2("d d");
ezMeasure m3("e e e");
ezMeasure m4("f f f f");
ezMeasure m5("g g g g g");
ezMeasure m6("a a a a a a");
ezMeasure m7("b b b b b b b");

// Create an empty part
ezPart p1;

// Add a measure to the part
p1.add(m1);
chout <= "Added 1 measure:" <= IO.newline();
p1.print(); 

// Duplicate the first measure two times
p1.duplicate(0, 2);
chout <= "Duplicated measure 0 two times:" <= IO.newline();
p1.print();

// Insert three measures at index 1
p1.insert(1, [m2, m3, m4]);
chout <= "Inserted 3 measures at index 1:" <= IO.newline();
p1.print();

// Replace measures 4 and 5 with three new measures
p1.replace(4, 2, [m5, m6, m7]);
chout <= "Replaced measures 4 and 5 with 3 new measures:" <= IO.newline();
p1.print();

// Delete measures 2, 3, and 4
p1.erase(2, 3);
chout <= "Deleted measures 2, 3, and 4:" <= IO.newline();
p1.print();
