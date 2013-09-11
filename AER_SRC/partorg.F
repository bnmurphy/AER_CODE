
#include "ctrparam.h"

! ================================================================
!
!  PARTORG.F:
!	subroutine  partorg
!
!  Purpose:
!	Calculate dynamic partitioning of organics in a volatility
!       basis set type set up
!
!  Author:
!	Ben Murphy
!
!  Revision:
!	Date    By		Brief Description
!	----    --		-----------------	
!       061013  Ben Murphy	created
!
! ================================================================

!	===================================================
	subroutine partorg
     &			(dtr, tempk, 
     &                   num, csulf0, sulf_rho0, caer,
     &                   cgas, dcaer, istate)
!	===================================================

! -------------------------------------------------
!  Brief Description of Dummy Variables:
!
!	dtr:	time step of integration in second
!       nmode:  number of aerosol modes
!       caer:   concentration of organic aerosol (ug/m3)
!       csulf:  concentration of aerosol (ug/m3)
!	cgas:   concentration of organic gas (ug/m3)
!       dcgas:  organic gas concentration change after
!               subroutine. [output]
!
! -------------------------------------------------	
        USE typedef_aerosol
	USE shared_data
	USE soadat
	USE partorg_mod
  
        IMPLICIT NONE

#include "aerodef.h"
             
	integer :: nmode, neq     
	integer :: imode, isoa, iter
	integer (kind=4) :: istate
        real :: pi, R, num(norgmode), tempk,
     &          yorg((norgmode+1)*nsoa), dtr, csulf0(norgmode),
     &          sulf_rho0(norgmode)
        real :: cgas(nsoa), caer(norgmode, nsoa), 
     &          ctot(nsoa), ctot2(nsoa),
     &          caer_sv(norgmode,nsoa), dcaer(norgmode,nsoa)
        real :: org_err, eps1, soa_mw(nsoa)
	logical :: numcheck


        !Should I include sulfate in the size calculation
        !For Modal approach, how do we represent size
	!check CMAQ


        !Declare and Explain Constants
        soa_mw(:) = soa_mw0(:) * 1.e-3 ! [kg/mol]
        !csat(isoa) = psat(isoa) / RT [ug/m3]
        !soa_rho(isoa) = density [kg/m3]
        pi = 3.1415
        R = 8.314472  !Gas constant J mol-1 K-1
	eps1 = 1e-18   !Small value for dividing by zero

        nmode = norgmode
	!Calculate Moments and Geometric Mean Diameter
        do imode = 1,nmode
          !Calculate the Moments using Eq. 4 from Binkowski 
	  !and Shankar (1995)
	  m0(imode) = num(imode) * 100**3   !N/cm3 -> N/m3

	  csulf(imode) = csulf0(imode) !ug/m3
	  sulf_rho(imode) = sulf_rho0(imode) * 1.e6*100**3 !ug/m3
        enddo


        !Calculate Physical Parameters
        do isoa = 1,nsoa
	  !Calculate T-Dependent Volatility (Cstar)
	  csat(isoa) = soa_cstar(isoa) * (soa_temp / tempk) *
     &                 exp( (soa_hvap(isoa)*1000/R)*
     &                      (1/soa_temp-1/tempk))
          !csat(isoa) = csat(isoa) * 1e-9  ! ug/m3 -> kg/m3

          !Convert SOA Density from g/cm3 to ug/m3
	  soa_rho(isoa) = soa_rho0(isoa) * 1.e6 * 100**3

	  !Calculate speed of org vapor molecules [m/s]
          cbar(isoa) = (8 * R * tempk / soa_mw(isoa) / pi)**(0.5)

	  !Calculate Diffusion Coefficient through Air [m2/s]
          soa_Dv = soa_Dn * (tempk/soa_temp)**soa_mu1
	enddo
 
	!Load Organic Mass Concentrations into Array
        ! y(1,...,nsoa) are the gas concns
	! y(nsoa+1,...,2*nsoa) are the aer concns for mode 1
	! y(2*nsoa+1,...,3*nsoa) are the aer concns for mode 2
	! y((nmode-1)*nsoa+1,...,nmode*nsoa) 
	!            are the aer concns for the final mode
        do isoa = 1,nsoa
	  yorg(isoa) = cgas(isoa)
	  do imode = 1,nmode
	    yorg( imode*nsoa+isoa ) = caer(imode,isoa)
	    caer_sv(imode,isoa) = caer(imode,isoa)
	  enddo

	  !Save total organic concentration to check later
	  ctot(isoa) = cgas(isoa) + sum(caer(:,isoa))
	enddo
	neq = nsoa * (nmode + 1)

        !INTEGRATE
        call solve_part_ode(dtr, neq, yorg, istate) 

        !Load cgas/caer arrays
        do isoa = 1,nsoa
	  cgas(isoa) = yorg(isoa)
	  do imode = 1,nmode
	    caer(imode,isoa) = yorg( imode*nsoa+isoa )
	  enddo
	enddo

	!Check for Numerical Errors
	numcheck = .false.
	iter = 0
	do while (.not.numcheck)
          iter = iter + 1
	  numcheck = .true.
          do isoa = 1,nsoa
	    if (cgas(isoa).lt.0.0) then !gas is negative
	      numcheck = .false.
	      print '(I3,A38,I1,2x,I1)',iter,') Found Negative gas in partorg. isoa=',isoa
	      print *,'    cgas=',cgas(isoa)
	      !Take spare SOA from the accum. mode
	      !because it has the most mass
	      caer(3,isoa) = caer(3,isoa) + cgas(isoa)
	      cgas(isoa) = 0.0
	    endif

            do imode = 1,nmode
	      if (caer(imode,isoa).lt.0.0) then
	        numcheck = .false.
		print '(I3,A50,I1,2x,I1)',iter,') Found Negative aerosol in partorg. imode, isoa:',imode,isoa
	        print *,'    caer=',caer(imode,isoa)
	        !Take spare SOA from the gas
	        !because it has the most mass
	        cgas(isoa) = cgas(isoa) + caer(imode,isoa)
	        caer(imode,isoa) = 0.0
	      endif
	    enddo
          enddo
	  if (iter.gt.500) goto 100 !Break out if more than 500 iterations
	enddo

 100    continue

        !Check that the Total Organic Concentration 
	!is conserved
	do isoa = 1,nsoa
	  ctot2(isoa) = cgas(isoa) + sum(caer(:,isoa))
	  do imode = 1,nmode
            dcaer(imode,isoa) = 
     &          caer(imode,isoa) - caer_sv(imode,isoa)
	  enddo
	enddo

	org_err = sum (abs(ctot2(:)-ctot(:)) / (ctot(:)+eps1))
	if (org_err.gt.0.05) then
	  print *,'Error in Partorg: Total Org. Conc has'
	  print *,'  changed by ',org_err*100,' percent during'
	  print *,'  the gas.particle partitioning routine.'
	  print *,'  ctot:  Before=',ctot,'  After=',ctot2

	  stop
	endif

        return
	end



!*********************************************************************
!
      subroutine solve_part_ode (dtr, neq, yorg,istate)
!
!      solve_part_ode is the wrapper for starting the ODE solver 
!      that calculates organic gas/particle partitioning.
!
!      Ben Murphy June 2013
!
!*********************************************************************

      IMPLICIT NONE

      external calc_org_flux, jac1

      integer (kind=4):: neq, itol, itask, istate, iopt
      integer (kind=4), parameter:: lrw=274 !22+9*neq+neq^2
      integer (kind=4), parameter:: liw=32  !20 + neq
      integer (kind=4):: iwork(liw), mf

      real (kind=8)   :: t, dtr, yorg(neq), rtol, atol(neq),
     &                   rwork(lrw)
      


      t = 0.  !Initial time
      itol = 2 !1 if atol is scalar; 2 if atol is array
      rtol = 1e-3 !relative tolerance  -3
      atol(01) = 1e-11 !Vapor          -6
      atol(02) = 1e-10 !Vapor          -4
      atol(03) = 1e-9  !Vapor          -4
      atol(04) = 1e-16 !Nucleation Mode  -16
      atol(05) = 1e-16 !Nucleation Mode  -16
      atol(06) = 1e-16 !Nucleation Mode  -16
      atol(07) = 1e-11 !Aitken Mode      -11
      atol(08) = 1e-11 !Aitken Mode      -11
      atol(09) = 1e-11 !Aitken Mode      -11
      atol(10) = 1e-11 !Accumulation Mode  -4
      atol(11) = 1e-11 !Accumulation Mode  -7
      atol(12) = 1e-11 !Accumulation Mode  -10
      itask = 1
      istate = 1
      iopt = 1
      iwork(5:10) = 0
      iwork(6) = 1000  !Maximum Number of Iterations
      rwork(5:10) = 0.0

      mf = 22 !Denotes Stiff methos solution with Jacobians
              !solved internally, not user-defined

      call dlsode( calc_org_flux, neq, yorg, t, dtr, itol, rtol, 
     &             atol, itask,
     &             istate, iopt, rwork, lrw, iwork, liw, jac1, mf)

      return
      end


!*********************************************************************
!
      subroutine calc_org_flux (neq, t, y, ydot)
     &                          
!
!      calc_org_flux is used by the ODE solver to actually calculate
!      the flux of mass to/from particles and gases
!
!      Ben Murphy June 2013
!
!*********************************************************************

        USE typedef_aerosol
	USE shared_data
	USE soadat
	USE partorg_mod
  
        IMPLICIT NONE

#include "aerodef.h"

 	integer :: nmode, neq     
        real :: t, ydot(neq), y(neq)
        real :: pi, R, num(norgmode)  
        real :: cgas(nsoa), caer(norgmode, nsoa), eps1
        integer :: isoa, imode
        real :: psi(nsoa), F3, stn, F_free3, F_cont3, GR
	real :: x_org

        pi = 3.1415
	R  = 8.314  !J mol-1 K-1
	eps1 = 1e-20 !Small value to avoid divide by zero


        !Load Local Arrays - cgas and caer
        nmode = norgmode
        do isoa = 1,nsoa
	  cgas(isoa) = y(isoa)  !ug/m3
	  do imode = 1,nmode
	    caer(imode,isoa) = y( imode*nsoa+isoa ) !ug/m3
	  enddo
	enddo
        ydot(:) = 0.0

        !Apply Particle Growth equations relevant to moments
	!developed by Whitby et al. (1991) and found in Binkowski
	!and Shankar (1995), appendix A2. 

	!Ignore Kelvin effect for now but FIX later for sure!


        !Calculate Size-Dependent Quantities
        do isoa = 1,nsoa
        do imode = 1,nmode
	  !Mass Fraction of each org species in a mode
	  x_org = caer(imode,isoa) / (sum(caer(imode,:)) + eps1)

          !Saturation Ratio (Cgas/Csat)
          stn = cgas(isoa)/(x_org*csat(isoa)+eps1) 
	  
	  !Calculate Psi - Mode-dependent b/c of mass fraction
	  psi(isoa) = x_org*csat(isoa) / soa_rho(isoa) *
     &                       (stn - 1.0)    !Dimensionless

	  !Third Moment
	  m3(imode) = !(csulf(imode) / sulf_rho(imode) +
     &                 sum(caer(imode,:) / soa_rho(:)) * 6.0/pi

          !Geometric Mean Diameter
          Dg(imode) = ( m3(imode) / (m0(imode)+eps1) / 
     &                  exp(4.5 * (log(msigma(imode)))**2.0) ) ** (1.0/3.0)

          !First Moment
          m1(imode) = m0(imode) * Dg(imode) * 
     &         exp(0.5 *(log(msigma(imode)))**2.0)

          !Second Moment
 	  m2(imode) = m0(imode) * Dg(imode)**2.0 * 
     &         exp(2.0 *(log(msigma(imode)))**2.0)


            !Size-Dep Flux for the Second Mode
            !F_free2(imode) = pi * soa_alpha * cbar(isoa) * 0.25 * m1(imode)
            !F_cont2(imode) = 2.0 * pi * Dv * m0(imode)
            !F2(imode) = F_free2(imode)*F_cont2(imode) /
            !&                  (F_free2(imode)+F_cont2(imode))

	    !Size-Dep Flux for the Third Mode
            F_free3 = pi * soa_alpha(isoa) * cbar(isoa) * 0.25 * m2(imode)
            F_cont3 = 2.0 * pi * soa_Dv * m1(imode)               
            F3 = F_free3*F_cont3 / (F_free3+F_cont3+eps1)
	    GR = psi(isoa)*F3 * pi/6.0 * soa_rho(isoa) 

	    !Change in Gas
	    ydot(isoa) = ydot(isoa) - GR
	    !Change in Aerosol
	    ydot( imode*nsoa+isoa ) = ydot( imode*nsoa+isoa) + GR
	  enddo
	enddo
 
	return
	 end	


!*********************
      subroutine jac1
        !this is just a dummy routine to pass
	!into the diff eq. solver.
      return
      end
!********************

