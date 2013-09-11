#include "ctrparam.h"
!
! A header file for SOA Parameters 
!
!	Ben Murphy
!
!==================================================================

       module soadat

       SAVE

       !Fix Standard Deviation For Now
       real, dimension(4) :: msigma = (/1.5, 1.55, 1.5, 2.0/)

#ifdef SOA_NVOL

!---
!----- NONVOLATILE CASE
!---     
	integer, parameter :: soanvol = 1
        integer, parameter :: nsoa = 3

        !Volatility
        real, dimension(nsoa) :: soa_cstar = (/1.e-6, 1.e-6, 1.e-6/) !ug/m3 

	!Enthalpy of Vaporization
        real :: soa_temp = 300 !K
        real, dimension(nsoa) :: soa_hvap = (/150.0, 150.0, 150.0/) !kJ/mol

        !Density
	real, dimension(nsoa) :: soa_rho0 = (/1.4, 1.4, 1.4/) !g/cm3

        !Accomodation Coefficient
	real, dimension(nsoa) :: soa_alpha = (/1.0,1.0,1.0/) !Dimensionless

	!Diffusion
	real :: soa_Dn  = (5.0e-6) !m2/s
	real :: soa_mu1 = (1.75) !Dimensionless
 
        !Molecular Weight
	real, dimension(nsoa) :: soa_mw0 = (/150.0, 150.0, 150.0/) !g/mol

        !SOA Yield
        !real, dimension(nsoa) :: isop_yld = (/0.002/)
        real, dimension(nsoa) :: isop_yld = (/0.01, 0.01, 0.01/)

#else
        
!---
!----- SEMIVOLATILE CASE
!---
        integer, parameter :: soanvol = 0
        integer, parameter :: nsoa = 3

        !Volatility
        real, dimension(nsoa) :: soa_cstar = (/1.e-1, 1.e2, 1.e5 /) !ug/m3 

	!Enthalpy of Vaporization
        real :: soa_temp = 300 !K
        real, dimension(nsoa) :: soa_hvap = (/150.0, 120.0, 90.0/) !kJ/mol
        !real, dimension(nsoa) :: soa_hvap = (/150.0, 150.0, 150.0/) !kJ/mol
        !real, dimension(nsoa) :: soa_hvap = (/100.0, 100.0, 100.0/) !kJ/mol
        !real, dimension(nsoa) :: soa_hvap = (/50.0, 50.0, 50.0/) !kJ/mol

        !Molecular Weight
	real, dimension(nsoa) :: soa_mw0 = (/150.0, 150.0, 150.0/) !g/mol

        !Density
	real, dimension(nsoa) :: soa_rho0 = (/1.4, 1.4, 1.4/) !g/cm3

        !Accomodation Coefficient
	real, dimension(nsoa) :: soa_alpha = (/1.0,1.0,1.0/) !Dimensionless

	!Diffusion
	real :: soa_Dn  = (5.0e-6) !m2/s
	real :: soa_mu1 = (1.75) !Dimensionless

        !SOA Yield (grams product / grams reactant)
        !real, dimension(nsoa) :: isop_yld = (/0.002/)
        real, dimension(nsoa) :: isop_yld = (/0.01, 0.05, 0.2/)
	!Yields from MCM: Chen et al. (2009)
        !real, dimension(nsoa) :: isop_yld = (/0.000175, 0.2807, 0.5689/)

#endif

       end module soadat
       

!***********************************************************************
!
       module partorg_mod
!
!      partorg_mod stores variables that change during the ODE integration
!      procedure
!
!***********************************************************************
 
       USE soadat
       SAVE

       integer, parameter :: norgmode = 3  !Nuc, Aitken, and Accum Modes
       real, dimension(norgmode) :: m0, m1, m2, m3, Dg,
     &                 csulf, sulf_rho
       real, dimension(nsoa) :: csat, cbar, soa_rho
       real :: soa_Dv


       end module partorg_mod
