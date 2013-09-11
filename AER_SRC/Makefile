##################################################
##  A makefile for CM 6.0			##
##    Chien Wang,  October 4, 2000		##
##    MIT					##
##################################################

# ================================================
# $Id: Makefile,v 1.8 2004/06/04 14:03:20 annica Exp $
# ================================================

##
## === Define files and directories
##

#PRNTDIR = /nobackup/misu1/x_benmu/OUTPUT/cm6amazon_triolith/
PRNTDIR = $(OUTDIR)/
##PRNTDIR = ./OUTPUT/
INCDIR  = ./INCLUDE/
EXEDIR  = ./

FILES	= cm3d6.F advcm.F tracebc.F c_eff.F advcxyzm.F advcsubx.F advcsuby.F advcsubz.F \
	 advq.F aerosol.F aq.F bc.F check.F chemfront.F cheminit.F chemtrop.F collect.F \
	 decomp.F distexch.F distribute.F exchange.F forward.F funcpack.F gridno.F initial.F isendcom.F lightning.F \
	 locatemem.F lsodesrc.F microphysics.F modelctl.F output.F \
	 pdadv.F radiag.F radiatov.F setrun.F solidtrop.F \
	 subgrid.F tq.F ud.F windadv.F budget.F drydep.F interp.F nucleate.F \
         scavenge.F impact.F calmean.F bin_nuc.F tern_nuc.F act_nuc.F \
	 budget_tracer.F budget_trans.F partorg.F

MODULES = typedef_gas.F typedef_aq.F typedef_hydrometeor.F \
	 typedef_solid.F typedef_state.F typedef_svalue.F typdef_aerosol.F \
	 shared_data.F soadat.F 
	 
FILESINC = $(INCDIR)ctrparam.h  $(INCDIR)patch_size.h $(INCDIR)homedir.h $(INCDIR)assign.h \
	 $(INCDIR)aeropar.h $(INCDIR)aerodef.h $(INCDIR)chemdef.h $(INCDIR)ccnindef.h \
	 $(INCDIR)fkdef.h $(INCDIR)ijpconv.h $(INCDIR)hydromtr12.h $(INCDIR)hydromtr.h \
	 $(INCDIR)budget.h $(INCDIR)raddef.h $(INCDIR)radia.h $(INCDIR)radcom.h \
	 $(INCDIR)state.h $(INCDIR)state12.h $(INCDIR)wind.h $(INCDIR)wind10.h \
	 $(INCDIR)wind1.h $(INCDIR)windall.h $(INCDIR)chemdef1.h $(INCDIR)aerodef1.h 

FILESDUMP = rcrm6amazon $(PRNTDIR)Q* $(PRNTDIR)N* \
	$(PRNTDIR)K $(PRNTDIR)T $(PRNTDIR)P* $(PRNTDIR)SPR \
	$(PRNTDIR)U $(PRNTDIR)V $(PRNTDIR)W $(PRNTDIR)rnumber \
	$(PRNTDIR)SPE $(PRNTDIR)DIAG $(PRNTDIR)DFRRO $(PRNTDIR)UV0 \
	$(PRNTDIR)RADDT $(PRNTDIR)RADFLUX \
	$(PRNTDIR)O3 $(PRNTDIR)CO* $(PRNTDIR)H* \
	$(PRNTDIR)NO* $(PRNTDIR)HNO3 $(PRNTDIR)C* $(PRNTDIR)S* \
	$(PRNTDIR)DMS $(PRNTDIR)CCN $(PRNTDIR)IN $(PRNTDIR)AQ* \
	$(PRNTDIR)*B $(PRNTDIR)AQ_BUDGET $(PRNTDIR)TROP_BUDGET

##
## === Compile, link and execute:
##
ifeq ($(CMPLER),PGI)
FC     := pgf90
#ifeq ($(SPMD),TRUE)
#FC     := mpif90
#endif
ifeq ($(R8),TRUE)
FFLAGS1 := -I./INCLUDE -fast -Mnolre -Mcache_align -i4 -r8 -tp k8-64
#FFLAGS1 := -I./INCLUDE -fast -Mnolre -Mcache_align -r8 -i4 -tp k8-64 -Mbounds -Mchkfpstk -Mchkptr -Mchkstk
#FFLAGS1 := -I./INCLUDE -g -fast -Mnolre -r8 -i4 -tp k8-64
else
FFLAGS1 := -I./INCLUDE -fast -Mnolre -Mcache_align -tp k8-64
#FFLAGS1 := -I./INCLUDE -fast -Mnolre -Mcache_align -tp k8-64 -Mbounds -Mchkfpstk -Mchkptr -Mchkstk
#FFLAGS1 := -I./INCLUDE -fast -tp k8-64
endif
ifeq ($(SPMD),TRUE)
#FFLAGSSPMD := -Mextend
FFLAGSSPMD :=
else
FFLAGSSPMD :=
endif
FFLAGS := $(FFLAGS1) $(FFLAGSSPMD)
FFLAGS2:= $(FFLAGS)
F90FLAGS := $(FFLAGS) -Mfree
LDFLAGS := 
endif

# -Nmpi - NSCs implementation of OpenMPI compiling
# -cpp  - Invoke the C preprocessor on Fortran source files
# -W1   - Warn general
# -FI   - Files are fixed format
# -FR   - Free-form code syntax.
# -O2   - Optimization
# -ipo  - enable multifile IP optimizations
# -r8   - Reals are 8 bytes large
# -prec_div - improve precision of FP divides. Some speed impact
# -fpe  - Specifies floating point exception behavior program-wide
#         0, 1, or 3. 0 means that all floating point overflows are
#         caught and cause failure. Underflows get set to 0. 1 means
#         overflows are ignored (they get infinity or NaN) but under-
#         flows are still set to 0. 3 means everything is ignored.
# -ftrapuv - Trap uninitialized variables.
# -warn all - Turn on all warnings
# -extend-source  - no hard cutoff on source code line endings
# -noerror-limit  - some option for the compiler to allow more errors
ifeq ($(CMPLER),INTEL)
    FC     := ifort
    #ifeq ($(SPMD),TRUE)  
    #FC     := mpif90     #This is turned off because NSC suggests we 
                      #use ifort -Nmpi as the compiler call
    #endif
    ifeq ($(R8),TRUE)
        FFLAGS := -I./INCLUDE -cpp -W1 -r8 -prec_div 
    else
        FFLAGS := -I./INCLUDE -cpp -FI  
    endif
    ifeq ($(SPMD),TRUE)
        FFLAGS :=$(FFLAGS) -Nmpi 
    endif
    ifeq ($(WARNINGS),TRUE)                  
        FFLAGS :=$(FFLAGS) -warn all #-diag-enable sc3 
    endif
    ifeq ($(DEBUG),TRUE)                  
        FFLAGS :=$(FFLAGS) -g -debug all -traceback -ftrapuv -CB -fpe0
    else
        FFLAGS :=$(FFLAGS) -fpe0 -O2 -traceback -ipo
    endif
    ifeq ($(LG_MEM),TRUE)                  
        FFLAGS :=$(FFLAGS) -mcmodel=medium -shared-intel
    else
        FFLAGS :=$(FFLAGS) -mcmodel=small #-static
    endif
    F90FLAGS:=$(FFLAGS) -FR -noerror-limit -extend-source
    FFLAGS:=$(FFLAGS) -extend-source -FI -noerror-limit 
    FFLAGS2:=$(FFLAGS)
    #LDFLAGS := -lPEPCF90
endif

#FFLAGS = -I./INCLUDE -cpp -w90 -w95 -FI -O3
#FFLAGS = -I./INCLUDE -fast -Mcache_align -tp p6
#FFLAGS = -I./INCLUDE -cpp -w90 -w95 -FI -O3 -prec_div -rcd -tpp6 -axK -xK -ipo -unroll

OBJECTS := cm3d6.o advcm.o tracebc.o c_eff.o advcxyzm.o advcsubx.o advcsuby.o advcsubz.o \
	 advq.o aerosol.o aq.o bc.o \
	 check.o chemfront.o cheminit.o chemtrop.o \
	 forward.o funcpack.o initial.o \
	 lightning.o lsodesrc.o microphysics.o modelctl.o \
	 output.o pdadv.o radiag.o radiatov.o setrun.o \
	 solidtrop.o subgrid.o tq.o ud.o windadv.o \
	 budget.o drydep.o interp.o nucleate.o \
         scavenge.o impact.o calmean.o bin_nuc.o tern_nuc.o \
         act_nuc.o budget_tracer.o budget_trans.o partorg.o

ifeq ($(SPMD),TRUE)
OBJECTS := $(OBJECTS) decomp.o isendcom.o
ifeq ($(CMPLER),PGI)
LDFLAGS := -L/usr/local/mpich/lib -lfmpich -lmpich -lpmpich $(LDFLAGS)
endif
ifeq ($(CMPLER),INTEL)
LDFLAGS := -Nmpi $(LDFLAGS)
endif
endif

#Library module for Fortran ODE solver (Ben Murphy, June 2013)
LDFLAGS := $(LDFLAGS) -L/home/x_benmu/lib/ODEPACK -lodepack

# === Modules: 0 grid define; 1 essential; d type define; s all
MOD0 := gridno.o 
MOD1 := $(MOD0) shared_data.o soadat.o
MODD := typedef_gas.o typedef_aq.o typedef_hydrometeor.o \
       typedef_state.o typedef_svalue.o typedef_solid.o \
       typedef_aerosol.o
ifeq ($(SPMD),TRUE)
MODP := exchange.o distribute.o
MODP2:= collect.o distexch.o
MODS := $(MOD1) $(MODD) $(MODP) $(MODP2)
else
MODS := $(MOD1) $(MODD)
endif

PROG = rcrm6amazon

##
## === Dependency
##

ALL: $(PROG)

$(PROG): $(OBJECTS)
	$(FC) $(FFLAGS) -o $@ $(OBJECTS) $(MODS) $(LDFLAGS)

OBJECTS : $(MODS) $(FILESINC)

cm3d6.o: cm3d6.F $(MODS) $(FILESINC)

gridno.o: gridno.F $(FILESINC)

typedef_svalue.o: typedef_svalue.F $(MOD1) $(FILESINC)

typedef_state.o: typedef_state.F $(FILESINC)

typedef_hydrometeor.o: typedef_hydrometeor.F $(FILESINC)

typedef_gas.o: typedef_gas.F $(FILESINC)

typedef_aq.o: typedef_aq.F $(FILESINC)

typedef_solid.o: typedef_solid.F $(FILESINC)

typedef_aerosol.o: typedef_aerosol.F $(FILESINC)

shared_data.o: shared_data.F $(MOD0) $(FILESINC)

soadat.o: soadat.F $(MOD0) $(FILESINC)

exchange.o: exchange.F $(MOD1) $(MODD) $(FILESINC)

collect.o: collect.F $(MOD1) $(MODD) $(FILESINC)

distribute.o: distribute.F $(MOD1) $(MODD) $(FILESINC)

distexch.o: distexch.F $(MOD1) $(MODD) $(MODP) $(FILESINC)

modelctl.o: modelctl.F $(MODS) $(FILESINC)

setrun.o: setrun.F $(MODS) $(FILESINC)

decomp.o: decomp.F $(MODS) $(FILESINC)

locatemem.o: locatemem.F $(MODS) $(FILESINC)

isendcom.o: isendcom.F $(MODS) $(FILESINC)

advq.o: advq.F $(MODS) $(FILESINC)

output.o: output.F $(MODS) $(FILESINC)

forward.o: forward.F $(MODS) $(FILESINC)

bc.o: bc.F $(MODS) $(FILESINC)

tq.o: tq.F $(MODS) $(FILESINC)

funcpack.o: funcpack.F $(MODS) $(FILESINC)

subgrid.o: subgrid.F $(MODS) $(FILESINC)

initial.o: initial.F $(MODS) $(FILESINC)

ud.o: ud.F $(MODS) $(FILESINC)

windadv.o: windadv.F $(MODS) $(FILESINC)

check.o: check.F $(MODS) $(FILESINC)

pdadv.o: pdadv.F $(MODS) $(FILESINC)

radiag.o: radiag.F $(MODS) $(FILESINC)

radiatov.o: radiatov.F $(MODS) $(FILESINC)

chemfront.o: chemfront.F $(MODS) $(FILESINC)

cheminit.o: cheminit.F $(MODS) $(FILESINC)

advcm.o: advcm.F $(MODS) $(FILESINC)

tracebc.o: tracebc.F $(MODS) $(FILESINC)

c_eff.o: c_eff.F $(MODS) $(FILESINC)

advcxyzm.o: advcxyzm.F $(MODS) $(FILESINC)

advcsubx.o: advcsubx.F $(MODS) $(FILESINC)

advcsuby.o: advcsuby.F $(MODS) $(FILESINC)

advcsubz.o: advcsubz.F $(MODS) $(FILESINC)

chemtrop.o: chemtrop.F $(MODS) $(FILESINC)

lsodesrc.o: lsodesrc.F $(MODS) $(FILESINC)

aerosol.o: aerosol.F $(MODS) $(FILESINC)

drydep.o: drydep.F $(MODS) $(FILESINC)

interp.o: interp.F $(MODS) $(FILESINC)

nucleate.o: nucleate.F $(MODS) $(FILESINC)

scavenge.o: scavenge.F $(MODS) $(FILESINC)

impact.o: impact.F $(MODS) $(FILESINC)

calmean.o: calmean.F $(MODS) $(FILESINC)

tern_nuc.o: tern_nuc.F $(MODS) $(FILESINC)

bin_nuc.o: bin_nuc.F $(MODS) $(FILESINC)

act_nuc.o: act_nuc.F $(MODS) $(FILESINC)

budget.o: budget.F $(MODS) $(FILESINC)

budget_tracer.o: budget_tracer.F $(MODS) $(FILESINC)

budget_trans.o: budget_trans.F $(MODS) $(FILESINC)

partorg.o: partorg.F $(MODS) $(FILESINC)

aq.o: aq.F $(MODS) $(FILESINC)

solidtrop.o: solidtrop.F $(MODS) $(FILESINC)

lightning.o: lightning.F $(MODS) $(FILESINC)

microphysics.o: microphysics.F $(MODS) $(FILESINC)


#
# === Rules
#

.SUFFIXES: .mod .F .F90

.F90.mod:
	$(FC) -c $(F90FLAGS) $<

.F.mod:
	$(FC) -c $(FFLAGS) $<

.F90.o:
	$(FC) -c $(F90FLAGS) $<

.F.o:
	$(FC) -c $(FFLAGS) $<

##
## === Functions
##

clean:
	rm -f *.o *.mod *.il *.d *.pc*

cleandump:
	rm $(FILESDUMP)

