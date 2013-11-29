package org.jruby.ir.instructions;

import org.jruby.ir.IRVisitor;
import org.jruby.ir.Operation;
import org.jruby.ir.operands.Variable;
import org.jruby.ir.transformations.inlining.InlinerInfo;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;

/*
 * Assign rest arg passed into method to a result variable
 */
public class ReceiveRestArgInstr extends ReceiveArgBase {
    /** Number of arguments already accounted for */
    public final int numUsedArgs;

    public ReceiveRestArgInstr(Variable result, int numUsedArgs, int argIndex) {
        super(Operation.RECV_REST_ARG, result, argIndex);
        this.numUsedArgs = numUsedArgs;
    }

    @Override
    public String toString() {
        return (isDead() ? "[DEAD]" : "") + (hasUnusedResult() ? "[DEAD-RESULT]" : "") + getResult() + " = " + getOperation() + "(" + numUsedArgs + ", " + argIndex + ")";
    }

    @Override
    public Instr cloneForInlining(InlinerInfo ii) {
        if (ii.canMapArgsStatically()) {
            // FIXME: Check this
            return new CopyInstr(ii.getRenamedVariable(result), ii.getArg(argIndex, true));
        } else {
            return new RestArgMultipleAsgnInstr(ii.getRenamedVariable(result), ii.getArgs(), argIndex, (numUsedArgs - argIndex), argIndex);
        }
    }

    @Override
    public Instr cloneForBlockCloning(InlinerInfo ii) {
        return new ReceiveRestArgInstr(ii.getRenamedVariable(result), numUsedArgs, argIndex);
    }

    private IRubyObject[] NO_PARAMS = new IRubyObject[0];

    @Override
    public IRubyObject receiveArg(ThreadContext context, int kwArgLoss, int numArgs, IRubyObject arg0, IRubyObject[] parameters) {
        IRubyObject[] args;
        int numAvailableArgs = numArgs - numUsedArgs - kwArgLoss;
        if (numAvailableArgs <= 0) {
            args = NO_PARAMS;
        } else {
            args = new IRubyObject[numAvailableArgs];
            // SSS: Quick simple hack
            if (parameters == null) {
                parameters = new IRubyObject[] { arg0 };
            }
            System.arraycopy(parameters, argIndex, args, 0, numAvailableArgs);
        }

        return context.runtime.newArray(args);
    }

    @Override
    public void visit(IRVisitor visitor) {
        visitor.ReceiveRestArgInstr(this);
    }
}
