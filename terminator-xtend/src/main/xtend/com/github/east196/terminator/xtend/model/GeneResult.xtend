package com.github.east196.terminator.xtend.model

import com.github.east196.terminator.xtend.bot.Bots
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString

@Accessors
@EqualsHashCode
@ToString(singleLine=true)
class GeneResult {
	CharSequence content
	CharSequence path
	
	new(CharSequence content, CharSequence path) {
		this.content=content
		this.path=path
	}

	def copy() {
		if(content.toString.isNullOrEmpty||path.toString.nullOrEmpty){
			println("content or path is null or empty!")
			return
		}
		Bots.copy(content, path.toString)
	}
}
