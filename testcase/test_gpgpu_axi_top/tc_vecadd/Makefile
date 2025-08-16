
help:
	@echo "========= help =================="
	@echo "make run-vcs-8w4t                "
	@echo "make run-vcs-4w8t                "
	@echo "make run-vcs-4w16t               "
	@echo "make run-vcs-4w32t               "
	@echo "make verdi                       "
	@echo "make clean                       "
	@echo "================================="

run-vcs-8w4t:
	vcs -full64 -LDFLAGS -Wl,--no-as-needed -R -sverilog -timescale=1ns/1ps -f ../common/run.f -debug_access+all +fsdb+functions -l simv.log +define+CASE_8W4T

run-vcs-4w8t:
	vcs -full64 -LDFLAGS -Wl,--no-as-needed -R -sverilog -timescale=1ns/1ps -f ../common/run.f -debug_access+all +fsdb+functions -l simv.log +define+CASE_4W8T +vcs+initreg+random +vcs+finish+1000000000  +ntb_random_seed_automatic

run-vcs-1w8t:
	vcs -full64 -LDFLAGS -Wl,--no-as-needed -R -sverilog -timescale=1ns/1ns -f ../common/run.f -debug_access+all +fsdb+functions -l simv.log +define+CASE_1W8T +vcs+initreg+random +vcs+finish+100000000  +ntb_random_seed_automatic -notice

run-vcs-4w16t:
	vcs -full64 -LDFLAGS -Wl,--no-as-needed -R -sverilog -timescale=1ns/1ps -f ../common/run.f -debug_access+all +fsdb+functions -l simv.log +define+CASE_4W16T

run-vcs-4w32t:
	vcs -full64 -LDFLAGS -Wl,--no-as-needed -R -sverilog -timescale=1ns/1ps -f ../common/run.f -debug_access+all +fsdb+functions -l simv.log +define+CASE_4W32T 

verdi:
	verdi -f ../common/run.f -ssf ./test.fsdb &

clean:
	rm -r ./simv* ./csrc ./verdiLog  ./ucli*  ./*.fsdb ./DVE* ./nova* ./*.h  AN.DB


# Generic rule for retrying any target
# Usage: make retry-run-vcs-8w4t
re-%:
	@until make $(subst re-,,$@); do \
		echo "VCS command failed, retrying in 60 seconds..."; \
		sleep 2; \
	done
