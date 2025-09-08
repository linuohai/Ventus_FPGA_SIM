
help:
	@echo "========= help =================="
	@echo "make run-mnist-small             "
	@echo "make run-mnist-tiny              "
	@echo "make verdi                       "
	@echo "make clean                       "
	@echo "================================="

run-mnist-small:
	vcs -full64 -LDFLAGS -Wl,--no-as-needed -R -sverilog -timescale=1ns/1ns -f ../common/run.f -debug_access+all +fsdb+functions \
	-l simv.log +define+MNIST_SMALL +vcs+initreg+random +vcs+finish+100000000000  +ntb_random_seed_automatic -notice

run-mnist-tiny:
	vcs -full64 -LDFLAGS -Wl,--no-as-needed -R -sverilog -timescale=1ns/1ns -f ../common/run.f -debug_access+all +fsdb+functions \
	-l simv.log +define+MNIST_TINY +vcs+initreg+random +vcs+finish+1000000000  +ntb_random_seed_automatic -notice

run-vcs-4w8t:
	vcs -full64 -LDFLAGS -Wl,--no-as-needed -R -sverilog -timescale=1ns/1ns -f ../common/run.f -debug_access+all +fsdb+functions -l simv.log +define+CASE_4W8T +vcs+initreg+random +vcs+finish+1000000000  +ntb_random_seed_automatic -notice

run-vcs-1w16t:
	vcs -full64 -LDFLAGS -Wl,--no-as-needed -R -sverilog -timescale=1ns/1ns -f ../common/run.f -debug_access+all +fsdb+functions -l simv.log +define+CASE_1W16T +vcs+initreg+random +vcs+finish+10000000000  +ntb_random_seed_automatic -notice

run-vcs-1w32t:
	vcs -full64 -LDFLAGS -Wl,--no-as-needed -R -sverilog -timescale=1ns/1ns -f ../common/run.f -debug_access+all +fsdb+functions -l simv.log +define+CASE_1W32T +vcs+initreg+random +vcs+finish+10000000000  +ntb_random_seed_automatic -notice

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