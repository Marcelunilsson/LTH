import org.jacop.constraints.Not;
import org.jacop.constraints.PrimitiveConstraint;
import org.jacop.core.FailException;
import org.jacop.core.IntDomain;
import org.jacop.core.IntVar;
import org.jacop.core.Store;
import org.jacop.constraints.XlteqC;
import java.util.Random;

public class SplitSearchLowerVarChoice {
    boolean trace = false;
    Store store;
    IntVar[] variablesToReport;
    int currentStoreDepth = 0;
    public int costValue = IntDomain.MaxInt;
    public IntVar costVariable = null;
    public long visitedNodes = 0;
    public long failedNodes = 0;

    public SplitSearchLowerVarChoice(Store s) {
        store = s;
    }

    public boolean label(IntVar[] vars) {
        visitedNodes++;
        ChoicePoint choice = null;
        boolean consistent;
        if (costVariable != null) {
            try {
                if (costVariable.min() < costValue) {
                    costVariable.domain.in(store.level, costVariable, costVariable.min(), costValue - 1);
                } else
                    return false;
            } catch (FailException f) {
                return false;
            }
        }

        consistent = store.consistency();

        if (!consistent) {
            return false;
        } else { // consistent
            if (vars.length == 0) {
                if (costVariable != null)
                    costValue = costVariable.min();
                reportSolution();
                return costVariable == null;
            }
            choice = new ChoicePoint(vars);
            progressLevel();
            store.impose(choice.getLowerDomainConstraint());
            consistent = label(choice.getSearchVariables());
            if (consistent) {
                reportSolution();
                regressLevel();
                return true;
            } else {
                failedNodes++;
                resetLevel();
                store.impose(new Not(choice.getLowerDomainConstraint()));
                consistent = label(vars);
                regressLevel();
                if (consistent) {
                    reportSolution();
                    return true;
                } else {
                    return false;
                }
            }
        }
    }

    void regressLevel() {
        store.removeLevel(currentStoreDepth);
        store.setLevel(--currentStoreDepth);
    }

    void progressLevel() {
        store.setLevel(++currentStoreDepth);
    }

    void resetLevel() {
        store.removeLevel(currentStoreDepth);
        store.setLevel(store.level);
    }

    public void reportSolution() {
        System.out.println("Nodes visited: " + visitedNodes);
        if (costVariable != null)
            System.out.println("Cost is " + costVariable);

        for (int i = 0; i < variablesToReport.length; i++)
            System.out.print(variablesToReport[i] + " ");
        System.out.println("\n----------------");
    }

    public void setVariablesToReport(IntVar[] v) {
        variablesToReport = v;
    }

    public void setCostVariable(IntVar v) {
        costVariable = v;
    }

    public class ChoicePoint {
        IntVar var;
        IntVar[] searchVariables;

        public ChoicePoint(IntVar[] v) {
            var = selectVariable(v);
        }

        public PrimitiveConstraint getLowerDomainConstraint() {
            return new XlteqC(var, (var.min() + var.max()) / 2);
        }

        public IntVar[] getSearchVariables() {
            return searchVariables;
        }

        IntVar selectVariable(IntVar[] v) {
            if (v.length != 0) {
                int count = 0;
                boolean[] sVar = new boolean[v.length];
                int biggestDomain = 0;
                int smallestDomain = 0;
                for (int i = 0; i < v.length; i++) {
                    sVar[i] = false;
                    if(v[i].domain.getSize() > v[biggestDomain].domain.getSize()) biggestDomain = i;
                    if(v[i].domain.getSize() < v[smallestDomain].domain.getSize()) smallestDomain = i;
                    if (v[i].domain.getSize() > 1) {
                        count++;
                        sVar[i] = true;
                    }
                }
                searchVariables = new IntVar[count];
                int countS = 0;
                for (int i = 0; i < v.length; i++) {
                    if (sVar[i]) {
                        searchVariables[countS] = v[i];
                        countS++;
                    }
                }
            // Return the last of searchVariables (only vars with domain size > 1) --> 
            //Total number of visited nodes = 54645
            //Total number of failed nodes = 27322
               
                if (searchVariables.length > 0) {
                    return searchVariables[searchVariables.length-1];
                } else{
                    return v[v.length-1];
                }
                

                

                //return biggest domain
                //Total number of visited nodes = 72889
                //Total number of failed nodes = 36444

                //return v[biggestDomain];

                //return v[v.length -1]
                //Total number of visited nodes = 73053
                //Total number of failed nodes = 36526

                //return v[v.length -1];


                //Smallest Domain
                //Total number of visited nodes = 56953
                //Total number of failed nodes = 28476

                //return v[smallestDomain];


                //v[0]
                //Total number of visited nodes = 41803
                //Total number of failed nodes = 20901

                //return v[0];


                //v[rand(v.length)]
                //Total number of visited nodes = 178913
                //Total number of failed nodes = 89456

                //Random rand = new Random();
                //return v[rand.nextInt(v.length)];


            } else {
                System.err.println("Zero length list of variables for labeling");
                return new IntVar(store);
            }
        }
    }
}