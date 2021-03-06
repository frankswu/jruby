package org.jruby.ir.operands;

import org.jruby.RubyString;
import org.jruby.runtime.DynamicScope;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;

/**
 * A String literal which can be shared and is frozen.
 */
public class ConstantStringLiteral extends StringLiteral {
    public ConstantStringLiteral(String s) {
        super(s);
    }

    @Override
    public Object retrieve(ThreadContext context, IRubyObject self, DynamicScope currDynScope, Object[] temp) {
        RubyString string = (RubyString) super.retrieve(context, self, currDynScope, temp);

        return context.runtime.freezeAndDedupString(string);
    }
}
