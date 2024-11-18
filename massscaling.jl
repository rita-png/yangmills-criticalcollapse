# ---------------------------------------------------------------------------
# Bisection search to look for apparent horizon formation
# ---------------------------------------------------------------------------

using CSV, Tables, DataFrames, Plots, Printf

include("./YangMills.jl");

#### CONFIG ####

global N=4000.0
global dir = "/home/user/YMmassscaling"


####

global bisection = true
global compactified = true
global zeroformat = true
global r0=0.3
global sigma=0.1

#### CONFIG ####


A_critic = 0.0886409955039620

exponents = collect(-25:0.25:-5)
global run = 1
global runmax = length(exponents)

while(run <= runmax)

    A = exp(exponents[run]) + A_critic

    println("\n########")
    println("\nBisection search run ##", run, "; A = ", A," N = ", N,", exponent = ", exponents[run],"\n")

    global ARGS = [A,run,N,sigma,r0]
    include("./Evolution_YangMills_Diff_Families.jl");
    
    df = CSV.read(dir*"/bisectionsearch/muninnDATA/even/parameters.csv", DataFrame)
    

    println("\nA = ",df[run+1, :Column2], " sigma = ", df[run+1, :Column3], " r0 = ", df[run+1, :Column4], " Final time = ", df[run+1, :Column5], " explode = ", df[run+1, :Column6], " black hole mass = ", df[run+1, :Column7])
    
    
    global run = run + 1
end


