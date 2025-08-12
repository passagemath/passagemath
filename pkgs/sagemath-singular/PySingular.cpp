// This is PySingular's SingularModule.cpp
// Copyright 2015-2019 Sebastian Gutsche <sebastian.gutsche@gmail.com>

#include <Python.h>

#include <iostream>
using std::cout;
using std::cerr;
using std::endl;

#include <string>
using std::string;

#include <Singular/libsingular.h>
#include <Singular/cntrlc.h>

string singular_return;
string singular_error;
string singular_warning;

bool singular_python_initialized = false;

/*
 * Singular init stuff
 */

void WerrorS_for_python(const char *s)
{
  singular_error += s;
}

void PrintS_for_python(const char *s)
{
  singular_return += s;
}

void WarningS_for_python(const char *s)
{
  singular_warning += s;
}

// void init_singular_for_python(){
//     siInit("/usr/local/bin/Singular"); //FIXME
//     init_signals();
//     errorreported = 0;
//     // init for output:
//     WerrorS_callback=WerrorS_for_python;
//     PrintS_callback=PrintS_for_python;
// 
//     singular_return = string();
//     singular_error = string();
// }

/*
 * Python functions
 */
extern int inerror;

static PyObject * InitializeSingular( PyObject* self, PyObject* args ){
    const char * path_to_singular_library;
    if (! PyArg_ParseTuple(args, "s", &path_to_singular_library) )
        return Py_False;
    char* path_non_const = const_cast<char*>(path_to_singular_library);
    siInit( path_non_const );
    init_signals();
    errorreported = 0;
    // init for output:
    WerrorS_callback=WerrorS_for_python;
    PrintS_callback=PrintS_for_python;

    singular_return = string();
    singular_error = string();
    singular_python_initialized = true;
    return Py_True;
}

static PyObject * RunSingularCommand( PyObject* self, PyObject* args ){
    
    if ( ! singular_python_initialized )
        return PyTuple_Pack( 2, Py_True, PyUnicode_FromString( "Please use InitializeSingular first" ) );
    
    singular_return.erase();
    singular_error.erase();
    const char * input_string;
    if (! PyArg_ParseTuple(args, "s", &input_string) )
        return NULL;
    
    const char return_str[] = "\nreturn();";
    char *ost = (char *)omalloc0(strlen(input_string) + sizeof(return_str)+1);
    strcpy(ost, input_string);
    strcat(ost,return_str);
//     myynest = 1;
    BOOLEAN err = iiAllStart(NULL, ost, BT_proc, 0);
    inerror = 0;
    errorreported = 0;
    omFree(ost);
    
    const char * return_string;
    PyObject* error;
    if(!err){
        return_string = singular_return.c_str();
        error = Py_False;
    }
    else{
        return_string = singular_error.c_str();
        error = Py_True;
    }
    
    return PyTuple_Pack( 2, error, PyUnicode_FromString( return_string ) );
    
}

extern char** singular_completion( char*, int, int );

static PyObject * GetSingularCompletion( PyObject* self, PyObject* args ){
    
    if ( ! singular_python_initialized )
        return PyTuple_Pack( 2, Py_True, PyUnicode_FromString( "Please use InitializeSingular first" ) );
    
    const char * input_string;
    int begin;
    int end;
    
    if (! PyArg_ParseTuple( args, "sii", &input_string, &begin, &end ) )
        return NULL;
    
    char* input_string_nonconst = const_cast<char*>(input_string);
    
    char** singular_complete_return = singular_completion( input_string_nonconst, begin, end );
    
    int pos = 0;
    PyObject * python_list = PyList_New(0);
    while( singular_complete_return[ pos ] ){
        PyList_Append( python_list, PyUnicode_FromString( singular_complete_return[ pos ] ) );
        pos++;
    }
    
    return python_list;
    
}


/*
 * Python init stuff
 */

// static PyMethodDef PySingularMethods[] = {
//     {"RunSingularCommand",  RunSingularCommand, METH_VARARGS,
//      "Runs a singular command"},
//     {"GetSingularCompletion", GetSingularCompletion, METH_VARARGS,
//      "Gets readline alike singular completion" },
//     {"InitializeSingular", InitializeSingular, METH_VARARGS,
//       "Initializes libsingular" },
//     {NULL, NULL, 0, NULL}        /* Sentinel */
// };
// 
// static struct PyModuleDef PySingularmodule = {
//    PyModuleDef_HEAD_INIT,
//    "PySingular",   /* name of module */
//    NULL, /* module documentation, may be NULL */
//    -1,       /* size of per-interpreter state of the module,
//                 or -1 if the module keeps state in global variables. */
//    PySingularMethods
// };
// 
// PyMODINIT_FUNC
// PyInit_PySingular(void)
// {
// //     init_singular_for_python();
//     return PyModule_Create(&PySingularmodule);
// }
// 
// /*
//  * main
//  */
// 
// wchar_t *GetWC(const char *c)
// {
//     const size_t cSize = strlen(c)+1;
//     wchar_t* wc = new wchar_t[cSize];
//     mbstowcs (wc, c, cSize);
// 
//     return wc;
// }
// 
// int main(int argc, char *argv[]){
// 
// #ifdef PYTHON_VERSION_OLDER_THREE_FIVE
//     const size_t cSize = strlen(argv[0])+1;
//     wchar_t* program = new wchar_t[cSize];
//     mbstowcs (program, argv[0], cSize);
// #else
//     wchar_t *program = Py_DecodeLocale(argv[0], NULL);
//     if (program == NULL) {
//         fprintf(stderr, "Fatal error: cannot decode argv[0]\n");
//         exit(1);
//     }
// #endif
// 
//     /* Add a built-in module, before Py_Initialize */
// 
//     PyImport_AppendInittab("PySingular", PyInit_PySingular);
//     /* Pass argv[0] to the Python interpreter */
//     
//     
//     Py_SetProgramName(program);
// 
//     /* Initialize the Python interpreter.  Required. */
//     Py_Initialize();
// 
//     /* Optionally import the module; alternatively,
//        import can be deferred until the embedded script
//        imports it. */
//     PyImport_ImportModule("PySingular");
// 
//     PyMem_RawFree(program);
//     return 0;
// }


/*
 * Python mixed init stuff
 */

struct module_state {
    PyObject *error;
};

#if PY_MAJOR_VERSION >= 3
#define GETSTATE(m) ((struct module_state*)PyModule_GetState(m))
#else
#define GETSTATE(m) (&_state)
static struct module_state _state;
#endif

static PyObject * error_out(PyObject *m) {
    struct module_state *st = GETSTATE(m);
    PyErr_SetString(st->error, "something bad happened");
    return NULL;
}

static PyMethodDef PySingularMethods[] = {
    {"RunSingularCommand",(PyCFunction)RunSingularCommand, METH_VARARGS,
     "Runs a singular command"},
    {"GetSingularCompletion",(PyCFunction)GetSingularCompletion, METH_VARARGS,
     "Gets readline alike singular completion" },
    {"InitializeSingular",(PyCFunction)InitializeSingular, METH_VARARGS,
      "Initializes libsingular" },
    {NULL, NULL, 0, NULL}        /* Sentinel */
};


static int PySingular_traverse(PyObject *m, visitproc visit, void *arg) {
    Py_VISIT(GETSTATE(m)->error);
    return 0;
}

static int PySingular_clear(PyObject *m) {
    Py_CLEAR(GETSTATE(m)->error);
    return 0;
}


static struct PyModuleDef moduledef = {
        PyModuleDef_HEAD_INIT,
        "PySingular",
        NULL,
        sizeof(struct module_state),
        PySingularMethods,
        NULL,
        PySingular_traverse,
        PySingular_clear,
        NULL
};


PyMODINIT_FUNC PyInit_PySingular(void)
{
    PyObject *module = PyModule_Create(&moduledef);

    if (module == NULL)
        return NULL;
    struct module_state *st = GETSTATE(module);

//     st->error = PyErr_NewException(const_cast<char*>("PyNormaliz.INITError"), NULL, NULL);
//     if (st->error == NULL) {
//         Py_DECREF(module);
//         return NULL;
//     }
    
//     NormalizError = PyErr_NewException(const_cast<char*>("Normaliz.error"), NULL, NULL );
//     Py_INCREF( NormalizError );
//     PyNormalizError = PyErr_NewException(const_cast<char*>("Normaliz.interface_error"), NULL, NULL );
//     Py_INCREF( PyNormalizError );
    
//     PyModule_AddObject( module, "error", NormalizError );
//     PyModule_AddObject( module, "error", PyNormalizError );

    return module;
}
