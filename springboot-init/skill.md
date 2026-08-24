---
name:springboot-init
description:当用户需要初始化springboot项目时使用
---

# Spring Boot 项目结构生成

基于 Spring Boot 3.5.7 + MyBatis-Plus + MySQL + Redis + JWT 快速创建标准 Java 后端项目骨架，包含统一返回、跨域配置、JWT 鉴权、用户注册登录等完整业务代码。

## 触发条件
当用户提出以下需求时使用此 skill：
- 初始化 Spring Boot 项目
- 或明确提到 springboot / Spring Boot 项目初始化

## 工作流程

### 第一步：收集信息

询问用户以下信息（如果用户一次性提供了全部信息则跳过此步）：

1. **groupId** — 如 `com.example`，默认 `com.example`
2. **artifactId** — 如 `demo`，项目目录名
3. **项目名称** — 默认使用 artifactId
4. **包名** — 默认使用 groupId + artifactId（如 `com.example.demo`）
5. **Spring Boot 版本** — 默认 `3.5.7`
6. **Java 版本** — 默认 `21`
7. **数据库名** — 默认将 artifactId 中的 `-` 替换为 `_`（如 `my-oj` → `my_oj`）
8. **端口号** — 默认 `8081`
9. **上下文路径** — 默认 `/api`（如不需要可为空）

如果用户没有指定，直接使用默认值，有疑问时再询问。

### 第二步：生成项目结构

在当前工作目录下创建 `<artifactId>/` 目录，按下面的结构生成所有文件。

## 占位符说明

> 生成每个文件时，将以下占位符替换为实际值，**不能有任何遗漏**：
>
> | 占位符 | 说明 | 示例 |
> |--------|------|------|
> | `{package}` | 完整包名 | `com.example.demo` |
> | `{package-path}` | 包名对应的目录路径 | `com/example/demo` |
> | `{groupId}` | Maven groupId | `com.example` |
> | `{artifactId}` | Maven artifactId | `demo` |
> | `{project-name}` | 项目显示名称 | `demo` |
> | `{spring-boot-version}` | Spring Boot 版本 | `3.5.7` |
> | `{java-version}` | Java 版本 | `21` |
> | `{db-name}` | 数据库名（artifactId 中 `-` 替换为 `_`） | `demo` |
> | `{application-class}` | 启动类名（artifactId 转驼峰 + Application） | `DemoApplication` |
> | `{port}` | 服务端口号 | `8081` |
> | `{context-path}` | 上下文路径 | `/api` |

## 项目结构模板

```
<artifactId>/
├── pom.xml
├── .gitignore
├── src/
│   ├── main/
│   │   ├── java/<package-path>/
│   │   │   ├── {application-class}.java
│   │   │   ├── common/
│   │   │   │   └── ResponseResult.java
│   │   │   ├── config/
│   │   │   │   ├── CorsConfig.java
│   │   │   │   └── WebConfig.java
│   │   │   ├── constant/
│   │   │   │   └── UserConstants.java
│   │   │   ├── context/
│   │   │   │   └── UserContext.java
│   │   │   ├── controller/
│   │   │   │   ├── HealthController.java
│   │   │   │   └── UserController.java
│   │   │   ├── dto/
│   │   │   │   ├── UserLoginDto.java
│   │   │   │   ├── UserRegisterDto.java
│   │   │   │   └── UserInfoDto.java
│   │   │   ├── entity/
│   │   │   │   └── User.java
│   │   │   ├── interceptor/
│   │   │   │   └── JwtInterceptor.java
│   │   │   ├── mapper/
│   │   │   │   └── UserMapper.java
│   │   │   ├── service/
│   │   │   │   ├── UserService.java
│   │   │   │   └── impl/
│   │   │   │       └── UserServiceImpl.java
│   │   │   └── util/
│   │   │       └── JwtUtil.java
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-dev.yml
│   │       ├── application-prod.yml
│   │       ├── mapper/
│   │       │   └── UserMapper.xml
│   │       └── sql/
│   │           └── user.sql
│   └── test/
│       └── java/<package-path>/
│           └── {application-class}Tests.java
```

## 文件模板

---

### 1. pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>{spring-boot-version}</version>
        <relativePath/>
    </parent>

    <groupId>{groupId}</groupId>
    <artifactId>{artifactId}</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>{project-name}</name>
    <description>{project-name}</description>

    <properties>
        <java.version>{java-version}</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-webflux</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>1.18.36</version>
            <optional>true</optional>
        </dependency>

        <dependency>
            <groupId>cn.hutool</groupId>
            <artifactId>hutool-all</artifactId>
            <version>5.8.37</version>
        </dependency>

        <dependency>
            <groupId>com.github.xiaoymin</groupId>
            <artifactId>knife4j-openapi3-jakarta-spring-boot-starter</artifactId>
            <version>4.4.0</version>
        </dependency>

        <!-- JWT support -->
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>0.12.6</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>0.12.6</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>0.12.6</version>
            <scope>runtime</scope>
        </dependency>

        <!-- MySQL driver -->
        <dependency>
            <groupId>com.mysql</groupId>
            <artifactId>mysql-connector-j</artifactId>
            <scope>runtime</scope>
        </dependency>

        <!-- MyBatis Plus (Spring Boot 3.x adapter) -->
        <dependency>
            <groupId>com.baomidou</groupId>
            <artifactId>mybatis-plus-spring-boot3-starter</artifactId>
            <version>3.5.10.1</version>
        </dependency>

        <!-- Redis -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-pool2</artifactId>
        </dependency>

    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

---

### 2. .gitignore

```gitignore
HELP.md
target/
.mvn/wrapper/maven-wrapper.jar
!**/src/main/**/target/
!**/src/test/**/target/

### STS ###
.apt_generated
.classpath
.factorypath
.project
.settings
.springBeans
.sts4-cache

### IntelliJ IDEA ###
.idea
*.iws
*.iml
*.ipr

### NetBeans ###
/nbproject/private/
/nbbuild/
/dist/
/nbdist/
/.nb-gradle/
build/
!**/src/main/**/build/
!**/src/test/**/build/

### VS Code ###
.vscode/

### OS ###
.DS_Store
Thumbs.db

### Logs ###
*.log
logs/

### Temp ###
*.tmp
*.bak
*.swp
*~

### Codegraph ###
.codegraph/
```

---

### 3. 启动类 — `{application-class}.java`

```java
package {package};

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class {application-class} {

    public static void main(String[] args) {
        SpringApplication.run({application-class}.class, args);
    }

}
```

---

### 4. 统一返回结果 — `common/ResponseResult.java`

```java
package {package}.common;

import lombok.Data;

/**
 * 统一返回结果
 */
@Data
public class ResponseResult<T> {
    private int code;
    private String message;
    private T data;

    public static <T> ResponseResult<T> success(T data) {
        ResponseResult<T> result = new ResponseResult<>();
        result.setCode(200);
        result.setMessage("success");
        result.setData(data);
        return result;
    }

    public static <T> ResponseResult<T> success(String message, T data) {
        ResponseResult<T> result = new ResponseResult<>();
        result.setCode(200);
        result.setMessage(message);
        result.setData(data);
        return result;
    }

    public static <T> ResponseResult<T> error(int code, String message) {
        ResponseResult<T> result = new ResponseResult<>();
        result.setCode(code);
        result.setMessage(message);
        return result;
    }

    public static <T> ResponseResult<T> error(String message) {
        return error(500, message);
    }

    public static <T> ResponseResult<T> error() {
        return error(500, "系统错误");
    }
}
```

---

### 5. 跨域配置 — `config/CorsConfig.java`

> 由于项目同时引入了 `spring-boot-starter-web` 和 `spring-boot-starter-webflux`，使用 WebFlux 版本的跨域配置以兼容两者。

```java
package {package}.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpHeaders;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.reactive.CorsWebFilter;
import org.springframework.web.cors.reactive.UrlBasedCorsConfigurationSource;

/**
 * 跨域配置（WebFlux 版本，兼容 Web MVC 和 WebFlux）
 */
@Configuration
public class CorsConfig {

    @Bean
    public CorsWebFilter corsWebFilter() {
        CorsConfiguration config = new CorsConfiguration();
        config.addAllowedOriginPattern("*");
        config.addAllowedMethod("*");
        config.addAllowedHeader("*");
        config.setAllowCredentials(true);
        config.addExposedHeader(HttpHeaders.CONTENT_DISPOSITION);
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return new CorsWebFilter(source);
    }
}
```

---

### 6. Web MVC 配置 — `config/WebConfig.java`

> 注册 JWT 拦截器，排除登录、注册、健康检查和 Knife4j 文档接口。

```java
package {package}.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import {package}.interceptor.JwtInterceptor;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Autowired
    private JwtInterceptor jwtInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // 添加JWT拦截器，排除登录、注册和健康检查接口
        registry.addInterceptor(jwtInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns("/user/login",
                        "/user/register",
                        "/health",
                        "/error",
                        // Swagger / Knife4j
                        "/doc.html",
                        "/swagger-ui/**",
                        "/swagger-resources/**",
                        "/v3/api-docs/**",
                        "/webjars/**",
                        "/favicon.ico"
                );
    }
}
```

---

### 7. 健康检查接口 — `controller/HealthController.java`

```java
package {package}.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 健康检查接口
 */
@RestController
@RequestMapping("/health")
public class HealthController {

    @GetMapping
    public String healthCheck() {
        return "ok";
    }
}
```

---

### 8. 用户实体 — `entity/User.java`

```java
package {package}.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("user")
public class User {
    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("username")
    private String username;

    @TableField("password")
    private String password;

    @TableField("email")
    private String email;

    @TableField("avatar")
    private String avatar;

    @TableField("profile")
    private String profile;

    @TableField("role")
    private String role;

    @TableField("create_time")
    private LocalDateTime createTime;

    @TableField("update_time")
    private LocalDateTime updateTime;

    @TableField("status")
    private Integer status; // 0-禁用, 1-启用
}
```

---

### 9. 用户 Mapper — `mapper/UserMapper.java`

```java
package {package}.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import {package}.entity.User;

@Mapper
public interface UserMapper extends BaseMapper<User> {
    User findByUsername(String username);
}
```

---

### 10. 用户 Mapper XML — `resources/mapper/UserMapper.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="{package}.mapper.UserMapper">

    <select id="findByUsername" resultType="{package}.entity.User">
        SELECT * FROM user WHERE username = #{username} AND status = 1
    </select>

</mapper>
```

---

### 11. 用户常量 — `constant/UserConstants.java`

```java
package {package}.constant;

public class UserConstants {
    public static final int SUCCESS_CODE = 200;
    public static final int ERROR_CODE = 500;
    public static final int UNAUTHORIZED_CODE = 401;
    public static final int FORBIDDEN_CODE = 403;

    public static final String SUCCESS_MESSAGE = "success";
    public static final String ERROR_MESSAGE = "error";
    public static final String UNAUTHORIZED_MESSAGE = "Unauthorized";
    public static final String REGISTER_SUCCESS = "注册成功";
    public static final String LOGIN_SUCCESS = "登录成功";
    public static final String USERNAME_EXISTS = "用户名已存在";
    public static final String EMAIL_EXISTS = "邮箱已被注册";
    public static final String USER_NOT_FOUND = "用户不存在";
    public static final String PASSWORD_ERROR = "密码错误";
    public static final String INVITE_CODE_ERROR = "邀请码无效";

    /** 有效邀请码列表 */
    public static final String[] VALID_INVITE_CODES = {"AGENT2026", "MYAGENT", "hyh666"};
}
```

---

### 12. 用户上下文（ThreadLocal）— `context/UserContext.java`

```java
package {package}.context;

import java.util.concurrent.ConcurrentHashMap;

public class UserContext {
    private static final ThreadLocal<Long> userIdHolder = new ThreadLocal<>();
    private static final ThreadLocal<String> usernameHolder = new ThreadLocal<>();

    /**
     * 用于 reactive/stream 场景下跨线程传递 userId。
     * key = conversationId, value = userId
     */
    private static final ConcurrentHashMap<String, Long> conversationUserMap = new ConcurrentHashMap<>();

    public static void setUserId(Long userId) {
        userIdHolder.set(userId);
    }

    public static Long getUserId() {
        return userIdHolder.get();
    }

    public static void setUsername(String username) {
        usernameHolder.set(username);
    }

    public static String getUsername() {
        return usernameHolder.get();
    }

    public static void clear() {
        userIdHolder.remove();
        usernameHolder.remove();
    }

    /**
     * 在请求线程中调用，将当前用户的 conversationId 与 userId 绑定，
     * 以便 reactive 流式处理线程中能通过 conversationId 找回 userId。
     */
    public static void registerConversationUser(String conversationId) {
        Long userId = getUserId();
        if (userId != null && conversationId != null) {
            conversationUserMap.put(conversationId, userId);
        }
    }

    /**
     * 作为 ThreadLocal 的 fallback，通过 conversationId 获取 userId。
     */
    public static Long getUserIdByConversationId(String conversationId) {
        if (conversationId == null) {
            return null;
        }
        return conversationUserMap.get(conversationId);
    }

    /**
     * 清理指定会话的用户映射
     */
    public static void removeConversationUser(String conversationId) {
        if (conversationId != null) {
            conversationUserMap.remove(conversationId);
        }
    }
}
```

---

### 13. JWT 工具类 — `util/JwtUtil.java`

```java
package {package}.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;

@Component
public class JwtUtil {

    private static final Logger log = LoggerFactory.getLogger(JwtUtil.class);

    @Value("${jwt.secret:mySecretKeyForDemoPurposeOnlyAndShouldBeChangedInProduction}")
    private String secret;

    @Value("${jwt.expiration:36000}") // 默认10小时
    private Long expiration;

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(secret.getBytes());
    }

    public String generateToken(Long userId, String username) {
        Date expirationDate = new Date(System.currentTimeMillis() + expiration * 1000);

        return Jwts.builder()
                .claim("userId", userId)
                .subject(username)
                .issuedAt(new Date())
                .expiration(expirationDate)
                .signWith(getSigningKey())
                .compact();
    }

    public Claims getClaimsFromToken(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (JwtException e) {
            throw new RuntimeException("Invalid JWT token", e);
        }
    }

    public Long getUserIdFromToken(String token) {
        Claims claims = getClaimsFromToken(token);
        Object rawUserId = claims.get("userId");
        if (rawUserId instanceof Number) {
            return ((Number) rawUserId).longValue();
        }
        return null;
    }

    public String getUsernameFromToken(String token) {
        Claims claims = getClaimsFromToken(token);
        return claims.getSubject();
    }

    public boolean validateToken(String token) {
        try {
            Claims claims = getClaimsFromToken(token);
            return !claims.getExpiration().before(new Date());
        } catch (JwtException e) {
            return false;
        }
    }
}
```

---

### 14. JWT 拦截器 — `interceptor/JwtInterceptor.java`

```java
package {package}.interceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import {package}.context.UserContext;
import {package}.util.JwtUtil;

@Component
public class JwtInterceptor implements HandlerInterceptor {

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 获取请求头中的token
        String token = request.getHeader("Authorization");

        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7); // 去掉 "Bearer " 前缀
        } else {
            // 如果没有token，则检查参数中是否有token
            token = request.getParameter("token");
        }

        if (token != null && jwtUtil.validateToken(token)) {
            // 验证通过，将用户信息存入ThreadLocal供后续使用
            UserContext.setUserId(jwtUtil.getUserIdFromToken(token));
            UserContext.setUsername(jwtUtil.getUsernameFromToken(token));
            return true;
        } else {
            // 验证失败，返回401
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"code\":401,\"message\":\"Unauthorized\"}");
            return false;
        }
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        UserContext.clear();
    }
}
```

---

### 15. DTO — 用户登录请求 `dto/UserLoginDto.java`

```java
package {package}.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UserLoginDto {
    @NotBlank(message = "用户名不能为空")
    private String username;

    @NotBlank(message = "密码不能为空")
    private String password;
}
```

---

### 16. DTO — 用户注册请求 `dto/UserRegisterDto.java`

```java
package {package}.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UserRegisterDto {
    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 20, message = "用户名长度必须在3-20之间")
    private String username;

    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 20, message = "密码长度必须在6-20之间")
    private String password;

    @Email(message = "邮箱格式不正确")
    @NotBlank(message = "邮箱不能为空")
    private String email;

    @NotBlank(message = "邀请码不能为空")
    private String inviteCode;
}
```

---

### 17. DTO — 用户信息返回 `dto/UserInfoDto.java`

```java
package {package}.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class UserInfoDto {
    private Long id;
    private String username;
    private String email;
    private String avatar;
    private String profile;
    private String role;
    private LocalDateTime createTime;
    private Integer status;
}
```

---

### 18. 用户服务接口 — `service/UserService.java`

```java
package {package}.service;


import {package}.common.ResponseResult;
import {package}.dto.UserInfoDto;
import {package}.dto.UserLoginDto;
import {package}.dto.UserRegisterDto;
import {package}.entity.User;

public interface UserService {
    ResponseResult<String> register(UserRegisterDto userRegisterDto);

    ResponseResult<String> login(UserLoginDto userLoginDto);

    ResponseResult<UserInfoDto> getCurrentUser(Long userId);

    ResponseResult<String> logout();

    User findByUsername(String username);

    boolean existsByUsername(String username);

    boolean existsByEmail(String email);
}
```

---

### 19. 用户服务实现 — `service/impl/UserServiceImpl.java`

```java
package {package}.service.impl;

import cn.hutool.crypto.digest.BCrypt;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import {package}.common.ResponseResult;
import {package}.constant.UserConstants;
import {package}.dto.UserInfoDto;
import {package}.dto.UserLoginDto;
import {package}.dto.UserRegisterDto;
import {package}.entity.User;
import {package}.service.UserService;
import {package}.mapper.UserMapper;
import {package}.util.JwtUtil;


import java.time.LocalDateTime;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    public ResponseResult<String> register(UserRegisterDto userRegisterDto) {
        // 检查用户名是否已存在
        if (existsByUsername(userRegisterDto.getUsername())) {
            return ResponseResult.error("用户名已存在");
        }

        // 检查邮箱是否已存在
        if (existsByEmail(userRegisterDto.getEmail())) {
            return ResponseResult.error("邮箱已被注册");
        }

        // 校验邀请码
        if (!isValidInviteCode(userRegisterDto.getInviteCode())) {
            return ResponseResult.error(UserConstants.INVITE_CODE_ERROR);
        }

        // 创建用户实体
        User user = new User();
        BeanUtils.copyProperties(userRegisterDto, user);
        // 密码加密
        user.setPassword(BCrypt.hashpw(userRegisterDto.getPassword()));
        user.setCreateTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());
        user.setStatus(1); // 启用状态

        // 保存用户
        int result = userMapper.insert(user);
        if (result > 0) {
            return ResponseResult.success("注册成功");
        } else {
            return ResponseResult.error("注册失败");
        }
    }

    @Override
    public ResponseResult<String> login(UserLoginDto userLoginDto) {
        // 根据用户名查找用户
        User user = findByUsername(userLoginDto.getUsername());
        if (user == null) {
            return ResponseResult.error("用户不存在");
        }

        // 验证密码
        if (!BCrypt.checkpw(userLoginDto.getPassword(), user.getPassword())) {
            return ResponseResult.error("密码错误");
        }

        // 生成JWT令牌
        String token = jwtUtil.generateToken(user.getId(), user.getUsername());

        return ResponseResult.success("登录成功", token);
    }

    @Override
    public ResponseResult<UserInfoDto> getCurrentUser(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            return ResponseResult.error(404, "用户不存在");
        }
        UserInfoDto userInfo = new UserInfoDto();
        BeanUtils.copyProperties(user, userInfo);
        return ResponseResult.success(userInfo);
    }

    @Override
    public ResponseResult<String> logout() {
        return ResponseResult.success("登出成功");
    }

    @Override
    public User findByUsername(String username) {
        return userMapper.findByUsername(username);
    }

    @Override
    public boolean existsByUsername(String username) {
        QueryWrapper<User> wrapper = new QueryWrapper<>();
        wrapper.eq("username", username);
        return userMapper.selectCount(wrapper) > 0;
    }

    @Override
    public boolean existsByEmail(String email) {
        QueryWrapper<User> wrapper = new QueryWrapper<>();
        wrapper.eq("email", email);
        return userMapper.selectCount(wrapper) > 0;
    }

    private boolean isValidInviteCode(String inviteCode) {
        if (inviteCode == null || inviteCode.isBlank()) {
            return false;
        }
        for (String validCode : UserConstants.VALID_INVITE_CODES) {
            if (validCode.equals(inviteCode.trim())) {
                return true;
            }
        }
        return false;
    }
}
```

---

### 20. 用户控制器 — `controller/UserController.java`

```java
package {package}.controller;

import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import {package}.context.UserContext;
import {package}.service.UserService;
import {package}.common.ResponseResult;
import {package}.dto.UserInfoDto;
import {package}.dto.UserLoginDto;
import {package}.dto.UserRegisterDto;

@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/register")
    @Operation(summary = "用户注册")
    public ResponseResult<String> register(@Valid @RequestBody UserRegisterDto userRegisterDto) {
        return userService.register(userRegisterDto);
    }

    @PostMapping("/login")
    @Operation(summary = "用户登录")
    public ResponseResult<String> login(@Valid @RequestBody UserLoginDto userLoginDto) {
        return userService.login(userLoginDto);
    }

    @GetMapping("/me")
    @Operation(summary = "获取当前用户信息")
    public ResponseResult<UserInfoDto> getCurrentUser() {
        return userService.getCurrentUser(UserContext.getUserId());
    }

    @PostMapping("/logout")
    @Operation(summary = "用户登出")
    public ResponseResult<String> logout() {
        return userService.logout();
    }

}
```

---

### 21. application.yml — 主配置

```yaml
spring:
  profiles:
    active: dev
  application:
    name: {artifactId}

server:
  port: {port}
  servlet:
    context-path: {context-path}

# MyBatis-Plus 配置
mybatis-plus:
  mapper-locations: classpath*:/mapper/**/*.xml
  type-aliases-package: {package}.entity
  global-config:
    db-config:
      id-type: auto
      logic-delete-field: deleted
      logic-delete-value: 1
      logic-not-delete-value: 0
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl

# Knife4j 配置
springdoc:
  swagger-ui:
    path: /swagger-ui.html
    tags-sorter: alpha
    operations-sorter: alpha
  api-docs:
    path: /v3/api-docs
  group-configs:
    - group: 'default'
      paths-to-match: '/**'
      packages-to-scan: {package}.controller

knife4j:
  enable: true
  setting:
    language: zh_cn
```

---

### 22. application-dev.yml — 开发环境

```yaml
spring:
  datasource:
      url: jdbc:mysql://localhost:3306/{db-name}?useUnicode=true&characterEncoding=utf-8&serverTimezone=Asia/Shanghai&useSSL=false
      username: root
      password: root
      driver-class-name: com.mysql.cj.jdbc.Driver

logging:
  level:
    {package}: debug
```

---

### 23. application-prod.yml — 生产环境

```yaml
spring:
  datasource:
      url: jdbc:mysql://localhost:3306/{db-name}?useUnicode=true&characterEncoding=utf-8&serverTimezone=Asia/Shanghai&useSSL=true
      username: ${DB_USERNAME:root}
      password: ${DB_PASSWORD:root}
      driver-class-name: com.mysql.cj.jdbc.Driver

server:
  port: ${SERVER_PORT:{port}}

mybatis-plus:
  configuration:
    log-impl: org.apache.ibatis.logging.nologging.NoLoggingImpl

logging:
  level:
    {package}: info
```

---

### 24. SQL 建表文件 — `resources/sql/user.sql`

```sql
-- 用户表
CREATE DATABASE IF NOT EXISTS {db-name} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE {db-name};

CREATE TABLE if not exists user (
                        `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
                        `username` VARCHAR(50) NOT NULL COMMENT '用户名',
                        `password` VARCHAR(100) NOT NULL COMMENT '密码',
                        `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
                        `avatar` VARCHAR(255) DEFAULT NULL COMMENT '头像URL',
                        `profile` TEXT DEFAULT NULL COMMENT '个人简介',
                        `role` VARCHAR(20) DEFAULT 'user' COMMENT '角色：admin/user',
                        `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                        `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                        `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用, 1-启用',
                        PRIMARY KEY (`id`),
                        UNIQUE KEY `uk_username` (`username`),
                        UNIQUE KEY `uk_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';
```

---

### 25. 测试类 — `{application-class}Tests.java`

```java
package {package};

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class {application-class}Tests {

    @Test
    void contextLoads() {
    }

}
```

---

## 生成注意事项

1. **包路径转换**：`{package}` 如 `com.example.demo` 需转换为目录路径 `com/example/demo/`，在 `src/main/java/` 和 `src/test/java/` 下分别创建对应目录结构。

2. **Application 类名**：根据 artifactId 转换驼峰命名，规则如下：
   - `demo` → `DemoApplication`
   - `user-service` → `UserServiceApplication`
   - `my-oj` → `MyOjApplication`
   - 即：以 `-` 分割，每段首字母大写，拼接后加 `Application`

3. **数据库名转换**：将 artifactId 中的 `-` 替换为 `_`，如 `my-oj` → `my_oj`。

4. **空目录处理**：不需要放 `.gitkeep` 文件，确保目录被创建即可。需创建的空目录：`dto/`、`vo/`（预留）。

5. **生成顺序**：建议按以下顺序生成文件，确保依赖关系清晰：
   1. 目录结构（先创建所有目录）
   2. pom.xml
   3. .gitignore
   4. 配置文件（application.yml → application-dev.yml → application-prod.yml）
   5. 基础类（ResponseResult → UserConstants → UserContext）
   6. 实体与数据层（User → UserMapper → UserMapper.xml）
   7. 工具与拦截器（JwtUtil → JwtInterceptor）
   8. 配置类（CorsConfig → WebConfig）
   9. 业务层（UserService → UserServiceImpl）
   10. 控制器（HealthController → UserController）
   11. DTO 类（UserLoginDto → UserRegisterDto → UserInfoDto）
   12. 启动类与测试类
   13. SQL 文件

6. **生成完成后提示用户**：
   - 用 IDE（如 IntelliJ IDEA）打开项目目录
   - 运行 `mvn clean compile` 验证项目能正常编译
   - 修改 `application-dev.yml` 中的数据库连接信息（用户名、密码）
   - 执行 `resources/sql/user.sql` 建表
   - 运行 `{application-class}` 启动项目
   - 访问 `http://localhost:{port}{context-path}/swagger-ui.html` 查看 Knife4j 接口文档
   - 先调用 `/health` 确认服务正常，再调用 `/user/register` 注册用户

7. **占位符替换检查清单**：生成每个文件后，自检以下占位符是否全部替换：
   - `{package}` / `{package-path}`
   - `{groupId}` / `{artifactId}` / `{project-name}`
   - `{spring-boot-version}` / `{java-version}`
   - `{db-name}` / `{application-class}`
   - `{port}` / `{context-path}`
   - **绝对不能有任何遗漏！**