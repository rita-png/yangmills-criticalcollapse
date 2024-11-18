

using CSV, Tables
using Dierckx


A = ARGS[1]
run = ARGS[2]
N = ARGS[3]
sigma = ARGS[4]
r0 = ARGS[5]

m = 1
res=m;

if compactified==true
    Xf=1.0
else
    Xf=2.0
end

dx=Xf/N

dt=0.5*round(dx,digits=10)

Nt=N
Tf=Nt*dt;

ori=0.0#Float128(0.0)#0.0;
initX1 = nothing
N=int(N)
initX1=range(ori, stop=Xf, step=dx);
initX = range(round(ori-3.0*dx,digits=10), stop=Xf+3.0*dx, step=dx)

L=length(initX);



####

initm=zeros(L)
initbeta=zeros(L)
initxi=zeros(L)
initderxi=zeros(L)

state_array=[initm initbeta initxi initderxi];

#WBAR,R
"""r0=0.3
sigma=0.1"""#defined in bisectionsearch.jl

initderxi[4:L-3] = init_derxi(initX1,r0,sigma,A)

state_array[:,4] = initderxi
state_array=ghost(state_array)

####
#XI FROM XI,X

derxi_func = Spline1D(initX[4:L-3], state_array[4:L-3,4],  k=4);

funcs=[derxi_func];

y0=[0.0 0.0 0.0]

state_array[4:L-3,1:3] = n_rk4wrapper(RHS,y0,initX[4:L-3],0,funcs,state_array[:,:]);

run=int(run)

global monitor_ratio = zeros(L);

if compactified==false
    global monitor_ratio[5:L-4] = 2 .* state_array[5:L-4,1] ./ initX[5:L-4]
else
    global monitor_ratio[5:L-4] = 2 .* state_array[5:L-4,1] ./ initX[5:L-4] .* (1 .- initX[5:L-4])
end

global files=["m", "beta", "xi", "derxi", "derderxi"]

derderxi=Der_arrayLOP(state_array,4,initX) .* (initX .- 1) .^ 2

global res=1
if zeroformat==true
    zero_print_muninn(files, 0, [state_array[:,1:4] derderxi],res,"w")
else
    print_muninn(files, 0, [state_array[:,1:4] derderxi],res,"w", initX)
end

print_monitorratio("monitorratio", 0, monitor_ratio[5:L-4],"w", initX[5:L-4])



time=0.0
criticality=0.0
explode=0.0
critical_stop=0
bondimass=0
evol_stats = [criticality A sigma r0 time explode run bondimass]

run=int(run)
if run == 1 && bisection==true
    
    CSV.write(dir*"/bisectionsearch/muninnDATA/even/parameters.csv", Tables.table(evol_stats))#, writeheader=true, header=["criticality", "A", "sigma", "r0", "time", "explode", "run"])
    
end

ginit=speed(initX,state_array[:,1],state_array[:,2])

finaltime=2
evol_stats, T_interp = timeevolution(state_array,finaltime,run);


if bisection==true
    
    CSV.write(dir*"/bisectionsearch/muninnDATA/even/parameters.csv", Tables.table(evol_stats),append=true)#, writeheader=true,header=["criticality", "A", "sigma", "r0", "time", "explode", "run"]);
    CSV.write(dir*"/bisectionsearch/muninnDATA/even/timearray.csv", Tables.table(T_interp))#, writeheader=false);
    

    
end





