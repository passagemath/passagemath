# sage_setup: distribution = sagemath-pari
# distutils: libraries = pari

cdef extern from "pari/pari.h" nogil:
    ctypedef unsigned long ulong "pari_ulong"
    ctypedef long* GEN
    ctypedef unsigned long pari_sp
    ctypedef long pari_timer

    ctypedef struct entree:
        entree* next
        char* name
        const char* help

    long    paricfg_version_code
    long    PARI_VERSION_SHIFT

    ctypedef struct pari_mainstack:
        pari_sp top

    pari_sp avma
    pari_mainstack * pari_mainstack
    GEN     gnil

    int     INIT_JMPm, INIT_SIGm, INIT_DFTm, INIT_noPRIMEm, INIT_noIMTm
    void    pari_init_opts(size_t parisize, ulong maxprime, ulong init_opts)
    void    pari_init(size_t parisize, ulong maxprime)
    void    pari_sighandler(int sig)

    void    (*cb_pari_err_recover)(long)

    void    pari_free(void*)

    GEN     gp_read_str_multiline(const char *t, char *last)
    char*   GENtostr(GEN x)
    void    pari_add_hist(GEN z, long t, long r)
    long    pari_nb_hist()

    long    timer_delay(pari_timer *T)
    long    timer_get(pari_timer *T)
    void    timer_start(pari_timer *T)

    long    walltimer_start(pari_timer *T)
    long    walltimer_delay(pari_timer *T)

    char*   gp_format_time(long delay)

    void    pari_puts(char*)
    void    pari_flush()

    struct PariOUT:
        void (*putch)(char)
        void (*puts)(const char*)
        void (*flush)()
    PariOUT* pariOut
    PariOUT* pariErr

    entree* is_entry(char *s)

    ctypedef struct PARI_plot:
        long width
        long height
        long hunit
        long vunit
        long fwidth
        long fheight
        void (*draw)(PARI_plot *T, GEN w, GEN x, GEN y)

    void pari_set_plot_engine(void (*T)(PARI_plot *))

    char* rect2svg(GEN w, GEN x, GEN y, PARI_plot *T)


cdef extern from "pari/paripriv.h" nogil:
    long    is_keyword_char(char c)

    ctypedef struct gp_data:
        int chrono
        pari_timer* T
        pari_timer* Tw

    gp_data* GP_DATA

    ctypedef struct pari_rl_interface:
        pass

    void    pari_use_readline(pari_rl_interface)
    char**  pari_completion_matches(pari_rl_interface*, char* s, long pos, long* wordpos)

    void    init_graph()


# It is important that this gets included *after* all PARI includes
cdef extern from "parifix.h":
    pass
