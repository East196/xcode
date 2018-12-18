package com.github.east196.xcode

import com.github.east196.xcode.bot.Bots
import com.github.east196.xcode.model.Field
import com.github.east196.xcode.model.Project
import com.github.east196.xcode.model.Record
import java.util.List

class Mysql2018 {

	def static void main(String[] args) {
		Base.init('''E:\backup\xcode\统一数据文档20181209.doc''').forEach [ three |
			gene(three.project, three.record, three.fields)
		]
	}


	def static gene(Project project, Record record, List<Field> fields) {

		val javaPath = project.root.split("\\.").join("\\")
		var packageName = record.name.toFirstLower

		var content = bean(project, record, fields)
		var path = '''«project.path»\src\main\java\«javaPath»\«packageName»\«record.name.toFirstUpper».java'''
		println(path)
		Bots.copy(content, path)

		content = dao(project, record, fields)
		path = '''«project.path»\src\main\java\«javaPath»\«packageName»\«record.name.toFirstUpper»Repository.java'''
		println(path)
		Bots.copy(content, path)

		content = controller(project, record, fields)
		path = '''«project.path»\src\main\java\«javaPath»\«packageName»\«record.name.toFirstUpper»Controller.java'''
		println(path)
		Bots.copy(content, path)

		content = validator(project, record, fields)
		path = '''«project.path»\src\main\java\«javaPath»\«packageName»\«record.name.toFirstUpper»Validator.java'''
		println(path)
		Bots.copy(content, path)

	}

	def static bean(Project project, Record record, List<Field> fields) {
		val basePackageName = project.root
		var klassType = record.name.toFirstUpper
		var packageName = record.name.toFirstLower
		var beanName = record.name.toFirstLower
		'''
package «basePackageName».«packageName»;

import java.util.List;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;

import org.hibernate.annotations.GenericGenerator;
import org.hibernate.annotations.ManyToAny;
import org.springframework.data.annotation.Transient;
import org.springframework.format.annotation.DateTimeFormat;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
«FOR f : fields»
«IF f.getKeyType=="M21"»
import «basePackageName».«f.javaType.toFirstLower».«f.javaType»;
«ENDIF»
«IF f.getKeyType=="12M"»
import «basePackageName».«f.javaType.toFirstLower».«f.javaType»;
«ENDIF»
«IF f.getKeyType=="121"»
import «basePackageName».«f.javaType.toFirstLower».«f.javaType»;
«ENDIF»
«ENDFOR»
import lombok.Data;
import lombok.ToString;

@Data
@ToString(exclude={«FOR f:fields»«IF f.keyType=="M21"|| f.keyType =="121"»"«f.name»",«ENDIF»«ENDFOR»}) 
@Entity
@JsonIgnoreProperties(ignoreUnknown = true, value = {"hibernateLazyInitializer", "handler", "fieldHandler"})
public class «klassType» {

	«FOR f : fields»
	/**«f.doc»**/
	«IF f.getKeyType=="P"»
	@Id
	@GenericGenerator(name="system-uuid", strategy="uuid") //这个是hibernate的注解/生成32位UUID
	@GeneratedValue(generator="system-uuid")
	@Column(length = 32)
	private «f.javaType» «f.name.toFirstLower»;
	«ELSEIF f.getKeyType=="M21"»
	@JsonIgnoreProperties(ignoreUnknown = true, value = {"«beanName»s"})
	@ManyToOne(fetch=FetchType.EAGER,optional=false)
	private «f.javaType» «f.name.toFirstLower»;
	«ELSEIF f.getKeyType=="12M"»
	@Transient
	@JsonIgnoreProperties(ignoreUnknown = true, value = {"«beanName»"})
	@OneToMany(fetch=FetchType.LAZY,mappedBy="«beanName»",orphanRemoval=false)
	private List<«f.javaType»> «f.name.toFirstLower»;
	«ELSEIF f.getKeyType=="121"»
	@OneToOne(fetch=FetchType.EAGER)
	private «f.javaType» «f.name.toFirstLower»;
	«ELSEIF f.type=="date"»
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    @JsonFormat(pattern="yyyy-MM-dd",timezone = "GMT+8")
	private «f.javaType» «f.name.toFirstLower»;
	«ELSEIF f.type=="datetime"»
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonFormat(pattern="yyyy-MM-dd HH:mm:ss",timezone = "GMT+8")
	private «f.javaType» «f.name.toFirstLower»;
	«ELSE»
	private «f.javaType» «f.name.toFirstLower»;
	«ENDIF»
	
	«ENDFOR»

}
		'''
	}

	def static dao(Project project, Record record, List<Field> fields) {
		val basePackageName = project.root
		var beanType = record.name.toFirstUpper
		var daoType = record.name.toFirstUpper + "Repository"
		var packageName = record.name.toFirstLower
		'''
package «basePackageName».«packageName»;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface «daoType» extends JpaRepository<«beanType», String>, JpaSpecificationExecutor<«beanType»>{
	
	«FOR f : fields»
	«IF f.getKeyType=="U"»
	public «beanType» findBy«f.name.toFirstUpper»(«f.javaType» «f.name»);
	«ENDIF»
	«ENDFOR»
	// add more ...
}
		'''
	}

	def static controller(Project project, Record record, List<Field> fields) {
		val basePackageName = project.root
		val commonPackageName = project.root.split("\\.").subList(0,project.root.split("\\.").length-1).join(".")
		var beanType = record.name.toFirstUpper
		var daoType = record.name.toFirstUpper + "Repository"
		var klassType = record.name.toFirstUpper + "Controller"
		var packageName = record.name.toFirstLower
		'''
package «basePackageName».«packageName»;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.domain.Sort.Order;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.validation.BindingResult;
import org.springframework.validation.DataBinder;
import org.springframework.validation.ObjectError;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import «commonPackageName».common.DynamicSpecifications;
import «commonPackageName».common.SearchFilter;
import «commonPackageName».common.vo.DataResponse;
import «commonPackageName».common.vo.Response;
import «commonPackageName».common.vo.TableResult;

@RestController
@RequestMapping("/controller/v1/«beanType.toFirstLower»")
public class «klassType» {

	private static final Logger LOGGER = LoggerFactory.getLogger(«klassType».class);

	@Autowired
	private «daoType» «daoType.toFirstLower»;

	@RequestMapping(value = "/", method = RequestMethod.GET)
	public DataResponse<List<«beanType»>> all(HttpServletRequest request) {
		Map<String, String[]> requestParameterMap = request.getParameterMap();
		List<SearchFilter> searchFilters = SearchFilter.from(requestParameterMap, «klassType».class);
		Specification<«beanType»> spec = DynamicSpecifications.bySearchFilter(searchFilters, «beanType».class);
		List<«beanType»> «beanType.toFirstLower»s = «daoType.toFirstLower».findAll(spec);
		return new DataResponse<List<«beanType»>>("0", "查询成功!", «beanType.toFirstLower»s);
	}
	
	@RequestMapping(value = "/page", method = RequestMethod.POST)
	public DataResponse<TableResult<List<«beanType»>>> page(
	@RequestParam(value = "pageNo", required = false, defaultValue = "1") Integer pageNo,
	@RequestParam(value = "pageSize", required = false, defaultValue = "20") Integer pageSize,
	@RequestBody Map<String, String> queryMap) {
		List<SearchFilter> searchFilters = SearchFilter.fromQueryMap(queryMap, «beanType».class);
		PageRequest pageRequest = PageRequest.of(pageNo-1, pageSize,Sort.by(Order.desc("id")));
    	Specification<«beanType»> spec = DynamicSpecifications.bySearchFilter(searchFilters, «beanType».class);
		Page<«beanType»> «beanType.toFirstLower»s = «daoType.toFirstLower».findAll(spec, pageRequest);
		TableResult<List<«beanType»>> tableResult = new TableResult<List<«beanType»>>();
		tableResult.setPageNo(«beanType.toFirstLower»s.getNumber()+1);
		tableResult.setPageSize(«beanType.toFirstLower»s.getSize());
		tableResult.setTotalCount(«beanType.toFirstLower»s.getTotalElements());
		tableResult.setTotalPage(«beanType.toFirstLower»s.getTotalPages());
		tableResult.setData(«beanType.toFirstLower»s.getContent());
		return new DataResponse<TableResult<List<«beanType»>>>("0", "查询成功!", tableResult);
	}	
	

	@RequestMapping(value = "/", method = RequestMethod.POST)
	public Response createOrUpdate(@RequestBody @Valid «beanType» «beanType.toFirstLower», BindingResult result) {
		LOGGER.debug("add «beanType.toFirstLower»:  {}", «beanType.toFirstLower»);
		if (result.hasErrors()) {
			StringBuffer sb = new StringBuffer();
			for (ObjectError msg : result.getAllErrors())
				sb.append(msg.getDefaultMessage()).append(" ");
			return new Response("-1", sb.toString());
		} else {
			«daoType.toFirstLower».save(«beanType.toFirstLower»);
		    return new Response("0", "ok");
		}
	}
	
	

	@RequestMapping(value = "/{id}", method = RequestMethod.DELETE)
	public Response delete(@PathVariable String id) {
		LOGGER.debug("id:  {}", id);
		«daoType.toFirstLower».deleteById(id);
		return new Response("0", "ok");
	}
	
	


	@RequestMapping(value = "/deletes", method = RequestMethod.POST)
	public Response «beanType.toFirstLower»Deletes(@RequestBody List<String> ids) {
		LOGGER.debug("ids:  {}", ids);
		for (String id : ids) {
			«daoType.toFirstLower».deleteById(id);
		}
		return new Response("0", "ok");
	}

	@InitBinder("«beanType.toFirstLower»")
	public void initBinder(DataBinder binder) {
		binder.setValidator(new «beanType»Validator());
	}
}
		'''
	}//TODO PUT 方法合并对象 

	def static validator(Project project, Record record, List<Field> fields) {
		val basePackageName = project.root
		var beanType = record.name.toFirstUpper
		var klassType = record.name.toFirstUpper + "Validator"
		var packageName = record.name.toFirstLower
		'''
package «basePackageName».«packageName»;

import org.springframework.validation.Errors;
import org.springframework.validation.ValidationUtils;
import org.springframework.validation.Validator;

public class «klassType» implements Validator {

	@Override
	public boolean supports(Class<?> klass) {
		return «beanType».class.equals(klass);
	}

	@Override
	public void validate(Object object, Errors errors) {
		«FOR f : fields.filter[it.required.equals("required")].toList»
		ValidationUtils.rejectIfEmpty(errors, "«f.name.toFirstLower»", null, "«f.label»不能为空！");
		«ENDFOR»
	}

}
	    '''
	}

}
