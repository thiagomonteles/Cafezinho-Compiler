# Cafezinho Compiler

This repository contains the implementation of a didactic compiler for the Cafezinho language, developed as part of the activities for the Compilers - 1 course in the Bachelor's Degree in Computer Science at the Federal University of Goiás.

## Project Structure

- **Lexical Analyzer**: Implemented using Flex, generating C code.
- **Syntax Analyzer**: Implemented using Bison.
- **Intermediate Representation**: Abstract syntax tree (ternary).
- **Final Compilation**: The syntax analyzer uses the lexical analyzer to process the input code and generate the syntax tree.

## Features

1. **Lexical Analysis**: Identification of tokens based on the definitions of the Cafezinho grammar.
2. **Syntax Analysis**: Construction of the abstract syntax tree from the tokens generated in the lexical analysis.
3. **Execution**: Generation of an executable that processes input files containing code in Cafezinho.

## Limitations

- The symbol table has not been implemented.
- Complete semantic analysis has not been performed.
- The final Assembly code has not been generated.

## Project Files

- `lexico.l`: Specification file for the Flex lexical analyzer generator.
- `Sintatico.y`: Specification file for the Bison syntax analyzer generator.
- `Makefile`: Commands for generating the lexical and syntax analyzers, compiling, and linking the main program.

## Usage Instructions

To compile and run the project, follow these steps:

1. **Compile the project**:
    ```sh
    make
    ```

2. **Run the analyzer**:
    ```sh
    ./cafezinho <input_file>
    ```

## Documentation

For more details, refer to the full specifications of the assignments and the provided grammars in the PDF files:

- `Especificação dos analisadores léxicos e sintáticos.pdf`
