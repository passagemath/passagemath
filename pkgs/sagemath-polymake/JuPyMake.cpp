#include <Python.h>

#include <iostream>
using std::cerr;
using std::cout;
using std::endl;

#include <string>

#include <polymake/Main.h>
#include <polymake/Vector.h>

#include <csignal>

#include <thread>

/*
 * Python different version stuff
 */

#define to_python_string(o) PyUnicode_FromString(o)

#define char_to_python_string(o)                                             \
    PyUnicode_FromString(std::string(1, o).c_str())

#define SET_SIGNAL_HANDLERS                                                  \
    sigset_t signal_block_set, signal_pending_set;                           \
    sigemptyset(&signal_block_set);                                          \
    sigaddset(&signal_block_set, SIGINT);                                    \
    sigaddset(&signal_block_set, SIGALRM);                                   \
    sigprocmask(SIG_BLOCK, &signal_block_set, NULL);

#define RESET_SIGNAL_HANDLERS                                                \
    sigpending(&signal_pending_set);                                         \
    if (sigismember(&signal_pending_set, SIGINT)) {                          \
        PyOS_sighandler_t current_handler = PyOS_setsig(SIGINT, SIG_IGN);    \
        sigprocmask(SIG_UNBLOCK, &signal_block_set, NULL);                   \
        PyOS_setsig(SIGINT, current_handler);                                \
        PyErr_SetString(PyExc_KeyboardInterrupt, "polymake interrupted");    \
        PyErr_SetInterrupt();                                                \
        PyErr_CheckSignals();                                                \
        return NULL;                                                         \
    }                                                                        \
    sigprocmask(SIG_UNBLOCK, &signal_block_set, NULL);


thread_local polymake::Main* main_polymake_session;
thread_local bool initialized;
bool shell_enabled;

PyObject*       JuPyMakeError;

static PyObject* ToPyBool(bool input)
{
    if (input)
        Py_RETURN_TRUE;
    Py_RETURN_FALSE;
}

/*
 * Python functions
 */
static PyObject* InitializePolymake(PyObject* self)
{
    if(!initialized){
    SET_SIGNAL_HANDLERS
        try {
            main_polymake_session = new polymake::Main;
            initialized = true;
            if(!shell_enabled){
                main_polymake_session->shell_enable();
                main_polymake_session->set_application("polytope");
            }
        }
        catch (const std::exception& e) {
            RESET_SIGNAL_HANDLERS
            PyErr_SetString(JuPyMakeError, e.what());
            return NULL;
        }
    RESET_SIGNAL_HANDLERS
    }
    Py_RETURN_TRUE;
}

static PyObject* ExecuteCommand(PyObject* self, PyObject* args)
{
    InitializePolymake(NULL);
    const char* input_string;
    if (!PyArg_ParseTuple(args, "s", &input_string))
        return NULL;
    std::string polymake_input(input_string);
    bool        parsed;
    std::string stdout;
    std::string stderr;
    std::string error;
    SET_SIGNAL_HANDLERS
    try {
        std::tie(parsed, stdout, stderr, error) =
            main_polymake_session->shell_execute(polymake_input);
    }
    catch (const std::exception& e) {
        RESET_SIGNAL_HANDLERS
        PyErr_SetString(JuPyMakeError, e.what());
        return NULL;
    }
    RESET_SIGNAL_HANDLERS
    return PyTuple_Pack(4, ToPyBool(parsed), to_python_string(stdout.c_str()),
                        to_python_string(stderr.c_str()),
                        to_python_string(error.c_str()));
}

static PyObject* GetCompletion(PyObject* self, PyObject* args)
{
    InitializePolymake(NULL);
    const char* input_string;
    if (!PyArg_ParseTuple(args, "s", &input_string))
        return NULL;
    std::string                polymake_input(input_string);
    std::vector< std::string > completions;
    int                        completion_offset;
    char                       additional_character;
    SET_SIGNAL_HANDLERS
    try {
        std::tie(completion_offset, additional_character, completions) =
            main_polymake_session->shell_complete(polymake_input);
    }
    catch (const std::exception& e) {
        RESET_SIGNAL_HANDLERS
        PyErr_SetString(JuPyMakeError, e.what());
        return NULL;
    }
    RESET_SIGNAL_HANDLERS
    int       completions_length = completions.size();
    PyObject* return_list = PyList_New(completions_length);
    for (int i = 0; i < completions_length; i++) {
        PyList_SetItem(return_list, i,
                       to_python_string(completions[i].c_str()));
    }
    return PyTuple_Pack(3, PyLong_FromLong(completion_offset),
                        char_to_python_string(additional_character),
                        return_list);
}

static PyObject*
GetContextHelp(PyObject* self, PyObject* args, PyObject* kwargs)
{
    InitializePolymake(NULL);
    const char*  input_string;
    int          position = -1;
    int          full = false;
    int          html = false;
    static char* kwlist[] = {"input", "position", "full", "html", NULL};
    if (!PyArg_ParseTupleAndKeywords(args, kwargs, "s|iii", kwlist,
                                     &input_string, &position, &full, &html))
        return NULL;
    std::string polymake_input(input_string);
    if (position == -1) {
        position = static_cast< int >(std::string::npos);
    }
    std::vector< std::string > results;
    SET_SIGNAL_HANDLERS
    try {
        results = main_polymake_session->shell_context_help(
            polymake_input, position, static_cast< bool >(full),
            static_cast< bool >(html));
    }
    catch (const std::exception& e) {
        RESET_SIGNAL_HANDLERS
        PyErr_SetString(JuPyMakeError, e.what());
        return NULL;
    }
    RESET_SIGNAL_HANDLERS
    int       results_length = results.size();
    PyObject* return_list = PyList_New(results_length);
    for (int i = 0; i < results_length; i++) {
        PyList_SetItem(return_list, i, to_python_string(results[i].c_str()));
    }
    return return_list;
}

/*
 * Python mixed init stuff
 */

struct module_state {
    PyObject* error;
};

#define GETSTATE(m) ((struct module_state*)PyModule_GetState(m))

static PyMethodDef JuPyMakeMethods[] = {
    {"ExecuteCommand", (PyCFunction)ExecuteCommand, METH_VARARGS,
     "Runs a polymake command"},
    {"GetCompletion", (PyCFunction)GetCompletion, METH_VARARGS,
     "Get tab completions of string"},
    {"GetContextHelp", (PyCFunction)GetContextHelp,
     METH_VARARGS | METH_KEYWORDS, "Get context help of string"},
    {"InitializePolymake", (PyCFunction)InitializePolymake, METH_NOARGS,
     "Initialize the polymake session"},

    {NULL, NULL, 0, NULL} /* Sentinel */
};


static int JuPyMake_traverse(PyObject* m, visitproc visit, void* arg)
{
    Py_VISIT(GETSTATE(m)->error);
    return 0;
}

static int JuPyMake_clear(PyObject* m)
{
    Py_CLEAR(GETSTATE(m)->error);
    return 0;
}


static struct PyModuleDef moduledef = {
    PyModuleDef_HEAD_INIT,       "JuPyMake",      NULL,
    sizeof(struct module_state), JuPyMakeMethods, NULL,
    JuPyMake_traverse,           JuPyMake_clear,  NULL};

#define INITERROR return NULL

PyMODINIT_FUNC PyInit_JuPyMake(void)
{
    PyObject* module = PyModule_Create(&moduledef);

    if (module == NULL)
        INITERROR;
    struct module_state* st = GETSTATE(module);
    JuPyMakeError = PyErr_NewException(
        const_cast< char* >("JuPyMake.PolymakeError"), NULL, NULL);
    Py_INCREF(JuPyMakeError);
    st->error = JuPyMakeError;

    return module;
}
