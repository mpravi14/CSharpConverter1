/***************************************************************************
 * Copyright 2012 by
 * + Christian-Albrechts-University of Kiel
 * + Department of Computer Science
 * + Software Engineering Group
 * and others.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ***************************************************************************/

package com.hcl.atma.converter.util;

import java.util.Arrays;
import org.antlr.runtime.CharStream;
import org.antlr.runtime.RecognitionException;

import com.hcl.atma.converter.parsers.CSharpPreProcessor;

public class CSharpPreProcessorImpl extends CSharpPreProcessor {

    public CSharpPreProcessorImpl(CharStream input,
            final String... macroDefinitions) {
        super(input);
        definedMacros.addAll(Arrays.asList(macroDefinitions));
        ifStack.push(Boolean.TRUE); // start with accepting tokens
    }

    @Override
    public void mTokens() throws RecognitionException {
        // if we are in a block that should not be parsed due to current macro
        // defs
        if (!ifStack.peek()) {
            mSkiPped_section_part();
        }
        else {
            super.mTokens();
        }
    }

}
