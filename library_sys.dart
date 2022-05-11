// ignore_for_file: unnecessary_string_interpolations, prefer_typing_uninitialized_variables

import 'dart:io';
import 'package:dart_console/dart_console.dart'; //imports an external package to use for clearscreen function

//class for student's information
class Student{
  late String fullName;
  late String address;
  var borrowedBooks = [];
  Student(this.fullName, this.address);
}

class Book{
  late String title;
  late String author;
  late String genre;
  // ignore: non_constant_identifier_names
  late String ISBN;
  late int status; //0 = borrowed, 1 = available
  var booksBorrowed = [];

  //constructor to set values of attributes for every book instance
  Book(this.title, this.author, this.genre, this.ISBN){
    status = 1; //status is immediately given value of 1 since it is available once added to collection
  }
}

class Inventory with searchIndex {
  var allBooks, lentBooks, bookList = [], studentList = [];
  final console = Console();

  List genre = ["Art & Recreation", "Computer Science", "History", "Philosophy", "Pure Science"];

  Inventory() {
    allBooks = 0;
    lentBooks = 0;
  }

  int totalBooks() {
    return allBooks;
  }

  int totalLent() {
    return lentBooks;
  }
  // ignore: non_constant_identifier_names
  void addBook(String title, String author, String genre, String ISBN) { //function call to add books to the inventory
    // ignore: unnecessary_new
    var book = new Book(title, author, genre, ISBN);
    bookList.add(book);
    allBooks++;
  }

  void browseBooks(var inv, int settings) {
    console.clearScreen();
    print('* * * * * Browse Books * * * * *\n');
    if(settings == 1) { //setting to print all books with status
      for(int i = 0; i < bookList.length; i++) {
        print("Title: ${bookList[i].title}");
        print("Author: ${bookList[i].author}");
        print("Genre: ${bookList[i].genre}");
        print("ISBN: ${bookList[i].ISBN}");
        if(bookList[i].status == 0) {
          print("Status: borrowed");
        }
        else {
          print("Status: available");
        }        
        print('\n');    
      } 
    }
    else {
      for(int i = 0; i < bookList.length; i++) {
        if(inv.bookList[i].status == 0) { // setting to print all books with rented status
          print("Title: ${bookList[i].title}");
          print("Author: ${bookList[i].author}");
          print("Genre: ${bookList[i].genre}");
          print("ISBN: ${bookList[i].ISBN}");
        }
      }
    }
  }
  void borrowBookProcess(int studentIndex) { //function to find book using isbn
    print('* * * * * Rent Book * * * * *\n');    
    console.clearScreen();
    for(var choice = '1'; choice != '2';) {
      print('1 - Add book ISBN\n2 - Done Adding');
      print('\nEnter Choice:');
      choice = stdin.readLineSync()!;

      if(choice == '1') {
        for(int bookIndex = -1; bookIndex == -1;) {
          print('\nEnter ISBN: ');
          String inputISBN = stdin.readLineSync()!;
          bookIndex = findBookIndex(bookList, inputISBN); //check if the isbn in available in booklist

          if(bookIndex == -1){
            print('Book not found.');
          }
          else if(bookList[bookIndex].status==0) {
            print('Book Found!');
            print('Currently the book is rented by someone else.');
          }
          else {
            print('Book Found!');
            studentList[studentIndex].borrowedBooks.add(bookList[bookIndex]); //adds the book to the student's borrowed books
            bookList[bookIndex].status = 0;
            lentBooks++;
            print('Book Added to list');
          }
        }
      }
    }
  }
  void borrowBook(var inv) { // borrow book function
    console.clearScreen();
    int studentIndex;
    print('* * * * * Borrow Books * * * * *\n');
    print('Enter Fullname: ');
    String fullName = stdin.readLineSync()!;
    print('Enter Address: ');
    String address = stdin.readLineSync()!;  
    print('1 - New User\n2 - Old User\n9 - Exit');
    print('Enter Choice: ');
    var choice = stdin.readLineSync();      
    switch (choice) {
      case '1': {
        inv.newStudent(fullName, address);
        studentIndex = inv.studentList.length-1;
        inv.borrowBookProcess(studentIndex);
        print('Exiting to menu in 5s...');
        sleep(const Duration(seconds: 5));
        userMenu(inv);
      }
        break;
      case '2': {
        studentIndex = inv.findStudentIndex(inv.studentList, fullName, address);
        if(studentIndex == -1) {
          print('You are not an existing user.');
        }
        else {
          inv.borrowBookProcess(studentIndex);
        print('Exiting to menu in 5s...');
        sleep(const Duration(seconds: 5));
        userMenu(inv);          
        }
      }
        break;
      case '9': {
        userMenu(inv);
      }
        break;
      default:
        print('Invalid Choice');
        sleep(const Duration(seconds: 5));
        borrowBook(inv);
    }
  }
  void returnBook(var inv) { //function to return book
    console.clearScreen();
    print('* * * * * Return Book * * * * *\n');
    print('Enter Fullname: ');
    String fullName = stdin.readLineSync()!;
    print('Enter Address: ');
    String address = stdin.readLineSync()!;    
    print('1 - New User\n2 - Old User\n9 - Exit');
    var choice = stdin.readLineSync();

    switch(choice) {
      case '1': {
        inv.newStudent(fullName, address);
        print('You have no rented books'); //since the student is a new user, it will return as no books
        sleep(const Duration(seconds: 5));
        returnBook(inv);
      }
        break;
      case '2': {
        int studentIndex = inv.findStudentIndex(inv.studentList, fullName, address); //check if student's fullname and address if it matches with in student record
        if(studentIndex != -1) { // student's credentials are found and proceeds to return process
          inv.returnProcess(studentIndex);
          sleep(const Duration(seconds: 5));
          returnBook(inv);
        }
        else { // the input credentials are not found in the student records
          print('Unknown Credentials');
          sleep(const Duration(seconds: 5));
          returnBook(inv);
        }
      }
        break;
      case '9': {
        print('Exiting in 5s...');
        sleep(const Duration(seconds: 5));
        userMenu(inv);
      }
        break;
      default:
        print('Invalid Choice');
        sleep(const Duration(seconds: 5));
        returnBook(inv);      
    } 
  }
  void returnProcess(int studentIndex) { //return process for the student's borrowed books
    var inv = Inventory();
    print('Returned Books: ');
    if(studentList[studentIndex].borrowedBooks.length!=0) { //checks if the student has rented books
      for(int i = 0; i < studentList[studentIndex].borrowedBooks.length;) {
        int bookIndex = findBookIndex(bookList, studentList[studentIndex].borrowedBooks[i].ISBN);
        studentList[studentIndex].borrowedBooks.removeAt(0); //removes the borrowed books from the student's borrowed books
        bookList[bookIndex].status = 1;
        lentBooks--;
        print("${bookList[bookIndex].title} by ${bookList[bookIndex].author}");
      }
    }
    else {
      print('You have no rented books.'); //returns the user to returnBook function
      returnBook(inv);
    }
    print('Exiting in 5s...');
    sleep(const Duration(seconds:5)); //returns the user to the user pick page
    userMenu(inv);
  }
  void newStudent(String fullName, String address) { // function that adds a new student to the studentList
    // ignore: unnecessary_new
    var student = new Student(fullName, address);
    studentList.add(student);
  }        
}    


mixin searchIndex{
  //method to search book index in the inventory's records using isbn
  // ignore: non_constant_identifier_names
  int findBookIndex(var listOfBooks, String ISBN){
    for(int i=0;i<listOfBooks.length;i++){
      if(listOfBooks[i].ISBN==ISBN) {
        return i;
      }
    }
    return -1;
  }

  //method to search user index in the student list using matched fullname and address
  int findStudentIndex(var listOfStudents, String fullName, String address){
    for(int i=0;i<listOfStudents.length;i++){
      if(listOfStudents[i].fullName==fullName && listOfStudents[i].address==address) {
        return i;
      }
    }
    return -1;
  }
}

void preAddBooks(var inv) { //function that uses addBook function to pre adds books to the inventory on start
  inv.addBook("Computer Science: An Interdisciplinary Approach", "Robert Sedgewick & Kevin Wayne", "Computer Science", "978-0-13-407642-3");
  inv.addBook("Types and Programming Languages", "Benjamin C. Pierce", "Computer Science", "978-0-26-216209-8");
  inv.addBook("The Color Purple", "Alice Walker", "Arts & Recreation", "978-0-14-313569-2");
  inv.addBook("Van Richten's Guide to Ravenloft (Dungeons & Dragons, 5th Edition)", "Wizards RPG Team", "Arts & Recreation","978-0-78-696725-4");
  inv.addBook("Timelines of History: The Ultimate Visual Guide to the Events that shaped the World", "DK", "History", "978-1-46-547002-7");
  inv.addBook("Storm Over Leyte: The Philippine Invasion and the Destruction of the Japanese Navy", "John Prados", "History", "9780451473615");
  inv.addBook("The Republic", "Plato", "Philosophy", "978-0-14-045511-3");
  inv.addBook("The Nicomachean Ethics", "Aristotle", "Philosophy", "978-0-14-044949-5");
  inv.addBook("The Rise and Fall of the Dinosaurs: A New History of a Lost World", "Steve Brusatte", "Pure Science", "978-0-06-249043-8");
  inv.addBook("Chasing New Horizons: Inside the Epic First Mission to Pluto", "Alan Stern & David Grinspoon", "Pure Science", "978-1-25-009896-2");
}

  void addBookProcess(var inv) {
    var console = Console();
    console.clearScreen();
    print('* * * * * Add Book * * * * *\n');
    print('Enter Book Title: ');
    String addtitle = stdin.readLineSync()!;
    print("Enter $addtitle's author: ");
    String addauthor = stdin.readLineSync()!;
    print('The genre of the book: ');
    String addgenre = stdin.readLineSync()!;
    print("Enter the book's ISBN: ");
    String addISBN = stdin.readLineSync()!;

    inv.addBook("$addtitle", "$addauthor", "$addgenre", "$addISBN");
    print('Added Book!\nExiting in 5s...');
    sleep(const Duration(seconds:5));
    adminMenu(inv);
  }

void main() { // main 
  var inv = Inventory();
  preAddBooks(inv); // function call to add premade book info
  userMenu(inv); // function call to choose user type
}

void userMenu(var inv) { //function to choose user type
  final console = Console();
  console.clearScreen();
  print('* * * * * Library * * * * *\n');
  print('1 - Student');
  print('2 - Teacher');
  print('9 - Exit');
  print('\nEnter choice: ');

  var choice = stdin.readLineSync();
  switch (choice) { // switch case to execute code based on the user's input
    case '1': {
      studentMenu(inv);
    }
      break;
    case '2': {
      adminMenu(inv);
    }
      break;
    case '9': {
      exit;
    }
      break;
    default: {
      userMenu(inv);
    }
  }
}

void adminMenu(var inv) { //page for librarian or teacher to use
  final console = Console(); //package call that will enable the use of clearscreen
  console.clearScreen();  // clears the screen
  print('* * * * * Library Admin * * * * *\n');
  print('1 - Total number of Books');
  print('2 - List Books');
  print('3 - See Lent Books');
  print('4 - Add Book');
  print('5 - Lend Book');
  print('6 - Return Book');
  print('9 - Exit');
  print('\nEnter choice: ');

  var choice = stdin.readLineSync();
  switch (choice) {
    case '1': { // prints the total number of books in inventory, by default it is 10
      int total = inv.totalBooks();
      print('Total Books: $total');
      print('Exiting in 5s');
      sleep(const Duration(seconds: 5));
      adminMenu(inv);
    }
      break;
    case '2': {
      int settings = 1; //setting to print all books regardless of status
      inv.browseBooks(inv,settings);
      int total = inv.totalBooks();
      print('Total books: $total');      
      sleep(const Duration(seconds:10));
      adminMenu(inv);
    }
      break;
    case '3': {
      int settings = 0; //setting to print all rented books only
      inv.browseBooks(inv,settings);   
      sleep(const Duration(seconds:10));
      adminMenu(inv);
    }
      break;
    case '4': {
      addBookProcess(inv); // function call to add book to inventory
    }
      break;
    case '5': {
      inv.borrowBook(inv);// function call to borrow book from library
    }
      break;
    case '6': {
      inv.returnBook(inv);// return books
    }    
      break;
    case '9': {
      userMenu(inv); //exits to choose user type page
    }
      break;                             
    default: { // if the user input is invalid
      adminMenu(inv);
    }
  }
}

void studentMenu(var inv)  {
  final console = Console();
  console.clearScreen();  
  print('* * * * * Student * * * * *\n');
  print('1 - Browse Books');
  print('2 - Borrow Book');
  print('3 - Return Book');
  print('9 - Exit');
  print('\nEnter choice: ');
  
  var choice = stdin.readLineSync();
  switch (choice) {
    case '1': {
      int settings = 1;
      inv.browseBooks(inv, settings);
      int total = inv.totalBooks();
      print('Total books: $total');      
      sleep(const Duration(seconds:10));
      studentMenu(inv);
    }
      break;
    case '2': {
      inv.borrowBook(inv);
    }
      break;
    case '3': {
      inv.returnBook(inv);
    }
      break;
    case '9': {
      userMenu(inv);
    }
      break;                           
    default:  {
      print('Invalid Choice');
      studentMenu(inv);
    }
  }
}