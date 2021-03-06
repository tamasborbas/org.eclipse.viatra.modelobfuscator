/*******************************************************************************
 * Copyright (c) 2010-2014, Abel Hegedus, Istvan Rath and Daniel Varro
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *   Abel Hegedus - initial API and implementation
 *******************************************************************************/
package org.eclipse.viatra.modelobfuscator.api

import org.eclipse.viatra.modelobfuscator.util.StringObfuscator
import java.util.Map

/**
 * Model obfuscators are used to modify an input model to 
 * conceal all sensitive details (especially String attribute values)
 * by replacing them with obfuscated values deterministically (to support restoration as well).
 * 
 * @author Abel Hegedus
 *
 */
interface ModelObfuscator {
  
  /**
   * Performs the obfuscation on the input model
   */  
  def void obfuscate()
  
  /**
   * Restores the obfuscated model as long as the obfuscator is
   * configured by the same values as the one used for obfuscation.
   */
  def void restore()
  
  def StringObfuscator getStringObfuscator()
  
  def Map<String,String> getObfuscationMap()
}